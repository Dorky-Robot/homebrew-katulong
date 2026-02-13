#!/usr/bin/env bash
set -e

# Katulong Manual Installer
# Use this if Homebrew installation fails (e.g., on macOS 26.x beta)

REPO_URL="https://github.com/dorky-robot/katulong.git"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.katulong}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "🚀 Katulong Manual Installer"
echo ""
echo "This installer will:"
echo "  1. Clone Katulong to $INSTALL_DIR"
echo "  2. Install dependencies"
echo "  3. Create symlink in $BIN_DIR"
echo ""

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
  echo "⚠️  Katulong is already installed at $INSTALL_DIR"
  read -p "Update to latest version? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  cd "$INSTALL_DIR"
  git pull
else
  # Clone repository
  echo "📦 Cloning Katulong..."
  git clone "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js is not installed."
  echo "Please install Node.js first:"
  echo "  - Via nvm: https://github.com/nvm-sh/nvm"
  echo "  - Via Homebrew: brew install node (if Homebrew works)"
  echo "  - Via nodejs.org: https://nodejs.org/"
  exit 1
fi

# Install dependencies
echo "📥 Installing dependencies..."
npm install --production --omit=dev --ignore-scripts

# Fix permissions for node-pty
chmod +x node_modules/node-pty/prebuilds/*/spawn-helper 2>/dev/null || true

# Create bin directory
mkdir -p "$BIN_DIR"

# Create symlink
echo "🔗 Creating symlink..."
ln -sf "$INSTALL_DIR/bin/katulong" "$BIN_DIR/katulong"

# Check if BIN_DIR is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "⚠️  $BIN_DIR is not in your PATH"
  echo ""
  echo "Add this to your ~/.zshrc or ~/.bashrc:"
  echo '  export PATH="$HOME/.local/bin:$PATH"'
  echo ""
  echo "Then run: source ~/.zshrc"
fi

echo ""
echo "✅ Katulong installed successfully!"
echo ""
echo "Usage:"
echo "  katulong --version       # Check version"
echo "  katulong start           # Start daemon and server"
echo "  katulong status          # Check status"
echo "  katulong open            # Open in browser"
echo ""
echo "Installation path: $INSTALL_DIR"
echo "Binary symlink: $BIN_DIR/katulong"
