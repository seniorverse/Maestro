#!/bin/bash
# Install custom Maestro build with web flow detection fix
# This script downloads and installs a custom Maestro build that allows
# using the same flow files for both iOS and web platforms.

set -e

MAESTRO_VERSION="${MAESTRO_VERSION:-2.0.10-custom}"
MAESTRO_REPO="${MAESTRO_REPO:-YOUR_USERNAME/maestro}"
INSTALL_DIR="${MAESTRO_INSTALL_DIR:-$HOME/.maestro}"

echo "Installing custom Maestro ${MAESTRO_VERSION}..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download the custom build
DOWNLOAD_URL="https://github.com/${MAESTRO_REPO}/releases/download/v${MAESTRO_VERSION}/maestro.zip"
echo "Downloading from: $DOWNLOAD_URL"

curl -fsSL "$DOWNLOAD_URL" -o /tmp/maestro.zip

# Extract
echo "Extracting..."
unzip -q -o /tmp/maestro.zip -d "$INSTALL_DIR"

# Clean up
rm /tmp/maestro.zip

# Make executable
chmod +x "$INSTALL_DIR/maestro/bin/maestro"

# Add to PATH for current session
export PATH="$INSTALL_DIR/maestro/bin:$PATH"

# For GitHub Actions, add to GITHUB_PATH
if [ -n "$GITHUB_PATH" ]; then
    echo "$INSTALL_DIR/maestro/bin" >> "$GITHUB_PATH"
    echo "Added Maestro to GITHUB_PATH"
fi

# Verify installation
echo "Verifying installation..."
"$INSTALL_DIR/maestro/bin/maestro" --version

echo ""
echo "Maestro installed successfully!"
echo ""
echo "Add this to your shell profile to use maestro:"
echo "  export PATH=\"$INSTALL_DIR/maestro/bin:\$PATH\""
