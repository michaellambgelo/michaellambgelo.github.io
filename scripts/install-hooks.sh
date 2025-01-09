#!/bin/sh

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy pre-push hook and make it executable
cp git-hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push

echo "Git hooks installed successfully!"
