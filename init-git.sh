#!/bin/bash
echo "Initializing Git Repository..."

# Check if git is already initialized
if [ -d ".git" ]; then
    echo "Git is already initialized."
else
    git init
    echo "Git repository initialized."
fi

# Add all files respecting .gitignore
git add .

# Commit
git commit -m "Initial commit: E-commerce microservices architecture"
echo "Initial commit created successfully."

echo ""
echo "To push this to a remote repository (e.g. GitHub), run:"
echo "git remote add origin <your-repo-url>"
echo "git branch -M main"
echo "git push -u origin main"
