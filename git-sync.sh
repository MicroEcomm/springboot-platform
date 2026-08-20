#!/bin/bash
echo "Syncing with remote repository..."

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Add all modifications
echo "Staging changes..."
git add .

# Commit if there's a message, else generic
COMMIT_MSG=${1:-"Update codebase"}
echo "Committing: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# Push
echo "Pushing to remote..."
git push origin main

echo "Sync complete!"
