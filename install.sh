#!/bin/bash

set -eufo pipefail

# Detect if we're being piped from curl (remote execution)
# If so, we need to clone the repo first
if [ ! -f "$(dirname "$0")/.chezmoidata/packages.yaml" ] 2>/dev/null; then
  echo "🚀  Remote execution detected. Cloning dotfiles repo..."
  TEMP_DIR=$(mktemp -d)
  git clone https://github.com/jad-haddad/dotfiles.git "$TEMP_DIR"
  echo "✓  Repo cloned to $TEMP_DIR"
  echo ""
  cd "$TEMP_DIR"
  exec bash "$TEMP_DIR/install.sh"
fi

echo ""
echo "🤚  This script will setup .dotfiles for you."

# Skip prompt in non-interactive mode (CI, Docker, etc.)
if [ -t 0 ] && [ -z "${CI:-}" ] && [ -z "${NONINTERACTIVE:-}" ]; then
  read -n 1 -r -s -p $'    Press any key to continue or Ctrl+C to abort...\n\n'
fi

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin*) echo "darwin" ;;
    Linux*)  echo "linux" ;;
    *)       echo "unknown" ;;
  esac
}

OS=$(detect_os)

# Install Homebrew (if missing)
command -v brew >/dev/null 2>&1 || \
  (echo '🍺  Installing Homebrew' && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

# Setup brew environment (OS-specific)
if [[ "$OS" == "darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  # Add Homebrew to path permanently (macOS only needs this once)
  if [[ ! -f ~/.zprofile ]] || ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
  fi
elif [[ "$OS" == "linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  # Add Homebrew to path permanently (Linux)
  if [[ ! -f ~/.zprofile ]] || ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.zprofile
  fi
fi

# Install chezmoi via brew
command -v chezmoi >/dev/null 2>&1 || \
  (echo '👊  Installing chezmoi' && brew install chezmoi)

# Initialize chezmoi
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "🚸  chezmoi already initialized"
else
  echo "🚀  Initializing dotfiles..."
  chezmoi init https://github.com/jad-haddad/dotfiles.git
fi

# Apply dotfiles
echo "🎯  Applying dotfiles..."
chezmoi apply

echo ""
echo "✅  Done!"
