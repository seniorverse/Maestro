#!/bin/bash
# Install custom Maestro build with web flow detection fix
# This script downloads and installs a custom Maestro build that allows
# using the same flow files for both iOS and web platforms.
#
# Mirrors the official Maestro installer behavior.

set -e

MAESTRO_VERSION="${MAESTRO_VERSION:-2.0.10-custom}"
MAESTRO_REPO="${MAESTRO_REPO:-seniorverse/Maestro}"
MAESTRO_DIR="${MAESTRO_DIR:-$HOME/.maestro}"
MAESTRO_TMP="${MAESTRO_DIR}/tmp"

# Safe rm -rf function that checks for dangerous paths
safe_rm_rf() {
    local target="$1"

    # Check if target is empty or a dangerous path
    if [[ -z "$target" ]]; then
        echo "Error: Cannot remove empty path"
        return 1
    fi

    # Block dangerous root-level paths
    case "$target" in
        /|/bin|/boot|/dev|/etc|/home|/lib|/lib64|/opt|/proc|/root|/run|/sbin|/srv|/sys|/tmp|/usr|/var)
            echo "Error: Refusing to remove dangerous path: $target"
            return 1
            ;;
    esac

    # Only remove if directory exists
    if [[ -d "$target" ]]; then
        rm -rf "$target"
    fi
}

echo "Installing custom Maestro ${MAESTRO_VERSION}..."

# Check dependencies
if ! command -v java > /dev/null; then
    echo "Error: java not found. Please install Java 17 or later."
    exit 1
fi

if ! command -v unzip > /dev/null; then
    echo "Error: unzip not found. Please install unzip."
    exit 1
fi

# Create directories
mkdir -p "$MAESTRO_TMP"

# Download
DOWNLOAD_URL="https://github.com/${MAESTRO_REPO}/releases/download/v${MAESTRO_VERSION}/maestro.zip"
echo "Downloading from: $DOWNLOAD_URL"
curl --fail --location --progress-bar "$DOWNLOAD_URL" -o "$MAESTRO_TMP/maestro.zip"

# Verify archive
echo "Checking archive integrity..."
ARCHIVE_OK=$(unzip -qt "$MAESTRO_TMP/maestro.zip" | grep 'No errors detected in compressed data')
if [[ -z "$ARCHIVE_OK" ]]; then
    echo "Downloaded zip archive is corrupt."
    exit 1
fi

# Extract
echo "Extracting..."
unzip -qo "$MAESTRO_TMP/maestro.zip" -d "$MAESTRO_TMP"

# Remove previous installation
echo "Removing previous installation (if any)..."
safe_rm_rf "$MAESTRO_DIR/lib"
safe_rm_rf "$MAESTRO_DIR/bin"

# Copy in place (zip contains maestro/ folder, copy its contents to MAESTRO_DIR)
echo "Installing..."
cp -rf "$MAESTRO_TMP"/maestro/* "$MAESTRO_DIR"

# Clean up
echo "Cleaning up..."
safe_rm_rf "$MAESTRO_TMP"

# Make executable
chmod +x "$MAESTRO_DIR/bin/maestro"

# For GitHub Actions, add to GITHUB_PATH
if [ -n "$GITHUB_PATH" ]; then
    echo "$MAESTRO_DIR/bin" >> "$GITHUB_PATH"
    echo "Added Maestro to GITHUB_PATH"
fi

# Verify installation
echo ""
echo "Verifying installation..."
"$MAESTRO_DIR/bin/maestro" --version

echo ""
echo "Maestro installed successfully!"
echo ""
echo "Run the following to add maestro to your PATH:"
echo ""
echo "    export PATH=\"\$PATH\":\"\$HOME/.maestro/bin\""
echo ""
