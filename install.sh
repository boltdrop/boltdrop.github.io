#!/bin/sh
set -e

REPO="boltdrop/boltdrop.github.io"
INSTALL_DIR="/usr/local/bin"
BIN="boltdrop"

# Detect OS and arch
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  ASSET="boltdrop-darwin-arm64.tar.gz" ;;
      x86_64) ASSET="boltdrop-darwin-amd64.tar.gz" ;;
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64)  ASSET="boltdrop-linux-amd64.tar.gz" ;;
      aarch64) ASSET="boltdrop-linux-arm64.tar.gz" ;;
      armv7l)  ASSET="boltdrop-linux-armv7.tar.gz" ;;
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

# Strip macOS quarantine (fixes Gatekeeper warning)
if [ "$OS" = "Darwin" ]; then
  xattr -dr com.apple.quarantine "$TMP/$BIN" 2>/dev/null || true
fi

chmod +x "$TMP/$BIN"

echo "Installing to $INSTALL_DIR..."
sudo mv "$TMP/$BIN" "$INSTALL_DIR/$BIN"

rm -rf "$TMP"

echo ""
echo "BoltDrop installed successfully!"
echo "Run: boltdrop"
