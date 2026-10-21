#!/bin/sh

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy each hook and make it executable. A hook that is already a symlink
# into git-hooks/ tracks the source on its own, so leave it alone.
for hook in pre-push pre-commit; do
    if [ ! -L ".git/hooks/$hook" ]; then
        cp "git-hooks/$hook" ".git/hooks/$hook"
    fi
    chmod +x "git-hooks/$hook" ".git/hooks/$hook"
done


echo "Git hooks installed successfully!"

# Check for optional dependencies
if ! which convert > /dev/null 2>&1; then
    echo ""
    echo "Note: ImageMagick 'convert' not found."
    echo "SEO images will NOT be auto-generated on commit."
    echo "Install with: brew install imagemagick"
fi
