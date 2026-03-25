#!/bin/sh

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy pre-push hook and make it executable
cp git-hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push

# Copy pre-commit hook and make it executable
cp git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit


echo "Git hooks installed successfully!"

# Check for optional dependencies
if ! which convert > /dev/null 2>&1; then
    echo ""
    echo "Note: ImageMagick 'convert' not found."
    echo "SEO images will NOT be auto-generated on commit."
    echo "Install with: brew install imagemagick"
fi
