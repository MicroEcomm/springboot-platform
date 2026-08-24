#!/bin/bash
# =============================================================================
# git-sync.sh — Robust Git Sync script for monorepo + submodules
# Automatically detects SSH/GPG availability and seamlessly degrades.
# Handles pulling, committing, and pushing across all submodules.
# =============================================================================

echo "====================================================="
echo "  1. Analyzing Authentication Capabilities"
echo "====================================================="

USE_SSH=false
USE_GPG=false

# Check SSH
if ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    USE_SSH=true
    echo "✅ SSH is configured and authenticated."
else
    echo "⚠️  SSH not fully authenticated. Attempting to load SSH agent..."
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent -s) > /dev/null
    fi
    ssh-add ~/.ssh/id_rsa 2>/dev/null || ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add 2>/dev/null || true
    
    if ssh -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        USE_SSH=true
        echo "✅ SSH loaded successfully."
    else
        echo "❌ SSH not available. Will fallback to HTTPS."
    fi
fi

# Check GPG
if command -v gpg >/dev/null 2>&1 && gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    if echo "test" | gpg --clearsign --batch --yes > /dev/null 2>&1; then
        USE_GPG=true
        echo "✅ GPG is ready and PIN is cached."
    else
        echo "GPG found. Testing signing (you may be prompted for PIN)..."
        if echo "test" | gpg --clearsign > /dev/null 2>&1; then
            USE_GPG=true
            echo "✅ GPG PIN cached successfully."
        else
            echo "❌ GPG signing failed or cancelled. Will proceed WITHOUT signing."
        fi
    fi
else
    echo "❌ No GPG keys found. Will proceed WITHOUT signing."
fi

echo ""
echo "====================================================="
echo "  2. Configuring Remotes (Main & Submodules)"
echo "====================================================="

# Function to fix URL based on SSH availability
fix_url() {
    local url=$1
    if [ "$USE_SSH" = true ]; then
        if [[ "$url" == https://github.com/* ]]; then
            echo "$url" | sed 's|https://github.com/|git@github.com:|'
        else
            echo "$url"
        fi
    else
        if [[ "$url" == git@github.com:* ]]; then
            echo "$url" | sed 's|git@github.com:|https://github.com/|'
        else
            echo "$url"
        fi
    fi
}

# Update main repo remote
MAIN_URL=$(git config --get remote.origin.url)
NEW_MAIN_URL=$(fix_url "$MAIN_URL")
if [ "$MAIN_URL" != "$NEW_MAIN_URL" ]; then
    git remote set-url origin "$NEW_MAIN_URL"
fi
echo "Main repo remote: $NEW_MAIN_URL"

# Update submodules remote
git submodule foreach --quiet '
    URL=$(git config --get remote.origin.url)
    if [ "'"$USE_SSH"'" = "true" ]; then
        if [[ "$URL" == https://github.com/* ]]; then
            NEW_URL=$(echo "$URL" | sed "s|https://github.com/|git@github.com:|")
            git remote set-url origin "$NEW_URL"
        fi
    else
        if [[ "$URL" == git@github.com:* ]]; then
            NEW_URL=$(echo "$URL" | sed "s|git@github.com:|https://github.com/|")
            git remote set-url origin "$NEW_URL"
        fi
    fi
'

echo ""
echo "====================================================="
echo "  3. Pulling Latest Changes (Main & Submodules)"
echo "====================================================="

echo "Pulling main repo..."
git pull origin main || git pull origin master || echo "⚠️ Failed to pull main repo."

echo "Pulling submodules..."
git submodule update --init --recursive
git submodule foreach 'git pull origin main || git pull origin master || true'

echo ""
echo "====================================================="
echo "  4. Committing and Pushing Submodules"
echo "====================================================="

GPG_FLAG=""
if [ "$USE_GPG" = true ]; then
    GPG_FLAG="-S"
else
    GPG_FLAG="--no-gpg-sign"
fi

COMMIT_MSG=${1:-"Automated code sync"}

git submodule foreach "
    if [[ -n \$(git status -s) ]]; then
        echo 'Changes found in \$name, committing...'
        git add .
        git commit $GPG_FLAG -m '\$COMMIT_MSG'
    fi
    
    LOCAL_COMMIT=\$(git rev-parse HEAD 2>/dev/null || echo '')
    REMOTE_COMMIT=\$(git ls-remote --heads origin refs/heads/\$(git rev-parse --abbrev-ref HEAD) 2>/dev/null | awk '{print \$1}')
    
    if [ -n \"\$LOCAL_COMMIT\" ] && [ \"\$LOCAL_COMMIT\" != \"\$REMOTE_COMMIT\" ]; then
        echo 'Pushing \$name...'
        git push origin HEAD || echo '⚠️ Failed to push \$name. Check authentication.'
    else
        echo '\$name is up to date.'
    fi
"

echo ""
echo "====================================================="
echo "  5. Committing and Pushing Main Repository"
echo "====================================================="

if [[ -n $(git status -s) ]]; then
    echo "Changes found in main repo, committing..."
    git add .
    git commit $GPG_FLAG -m "$COMMIT_MSG"
fi

echo "Pushing main repo..."
git push origin main || git push origin master || echo "⚠️ Failed to push main repo. Check authentication."

echo ""
echo "====================================================="
if [ "$USE_SSH" = false ]; then
    echo "⚠️ NOTE: You pushed via HTTPS."
    echo "GitHub REQUIRES a Personal Access Token (PAT) for HTTPS pushes."
    echo "If it asked for a password and failed, you must use a PAT instead of your account password."
fi
echo "  Sync Complete!"
echo "====================================================="
