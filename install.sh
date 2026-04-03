#!/bin/sh
set -e

REPO="boltdrop/boltdrop.github.io"
INSTALL_DIR="/usr/local/bin"
BIN="boltdrop"

# Detect OS and arch
OS="$(uname -s)"
ARCH="$(uname -m)"

# Fetch the latest version tag
VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"v\([^"]*\)".*/\1/')"
if [ -z "$VERSION" ]; then
  echo "Error: could not determine latest version"; exit 1
fi

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  ASSET="boltdrop_${VERSION}_darwin_arm64.tar.gz" ;;
      x86_64) ASSET="boltdrop_${VERSION}_darwin_amd64.tar.gz" ;;
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64)  ASSET="boltdrop_${VERSION}_linux_amd64.tar.gz" ;;
      aarch64) ASSET="boltdrop_${VERSION}_linux_arm64.tar.gz" ;;
      armv7l)  ASSET="boltdrop_${VERSION}_linux_armv7.tar.gz" ;;
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"
TMP="$(mktemp -d)"

echo "Downloading BoltDrop for ${OS}/${ARCH}..."
curl -fsSL "$URL" -o "$TMP/$ASSET"

echo "Extracting..."
tar -xzf "$TMP/$ASSET" -C "$TMP"

# The binary inside the archive is named 'boltdrop'
EXTRACTED="$TMP/boltdrop"
if [ ! -f "$EXTRACTED" ]; then
  echo "Error: could not find binary after extraction"
  exit 1
fi

chmod +x "$EXTRACTED"

echo "Installing to $INSTALL_DIR/$BIN..."
sudo mv "$EXTRACTED" "$INSTALL_DIR/$BIN"

# Strip macOS quarantine from final installed path (fixes Gatekeeper blocking the binary)
if [ "$OS" = "Darwin" ]; then
  sudo xattr -dr com.apple.quarantine "$INSTALL_DIR/$BIN" 2>/dev/null || true
fi

rm -rf "$TMP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  BoltDrop installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Start transferring files:"
echo "    boltdrop"
echo ""
echo "  Help & options:"
echo "    boltdrop --help"
echo ""
echo "  Specify a port (default: 7474):"
echo "    boltdrop --port 8080"
echo ""
echo "  More info: https://boltdrop.github.io"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
