#!/bin/bash
# Integration test for dotfiles - VERBOSE MODE

set -e

echo "🧪 Dotfiles Integration Test - Ubuntu 24.04"
echo "============================================"
echo ""

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📦 Pulling Ubuntu 24.04..."
docker pull ubuntu:24.04
echo "✓ Image ready"
echo ""

echo "🚀 Running installation test..."
echo "This will take 3-5 minutes. You'll see all the output."
echo ""

# Run in container with FULL verbose output
docker run --rm -v "$REPO_ROOT:/dotfiles:ro" ubuntu:24.04 bash -c "
set -e

echo '=== STEP 1: Installing base dependencies ==='
apt-get update
apt-get install -y curl git sudo build-essential procps file ca-certificates software-properties-common gnupg lsb-release zsh vim tmux
echo '✓ Base dependencies installed'
echo ''

echo '=== STEP 2: Creating test user ==='
useradd -m -s /bin/zsh testuser
echo 'testuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
echo '✓ Test user created'
echo ''

echo '=== STEP 3: Copying dotfiles ==='
su - testuser -c 'mkdir -p ~/.local/share && cp -r /dotfiles ~/.local/share/chezmoi'
echo '✓ Dotfiles copied'
echo ''

echo '=== STEP 4: Running install.sh ==='
echo 'Starting dotfiles installation...'
su - testuser -c 'export NONINTERACTIVE=1 CI=true && bash ~/.local/share/chezmoi/install.sh'
echo ''
echo '✓ Installation complete!'
echo ''

echo '=== STEP 5: Running verification tests ==='
su - testuser -c '
cd ~
errors=0

echo \"Checking dotfiles...\"
for f in .zshrc .tmux.conf .gitconfig .zshenv .zsh_aliases .config/starship.toml; do
  if [ -f \"\$f\" ]; then
    echo \"  ✓ \$f exists\"
  else
    echo \"  ✗ \$f MISSING\"
    ((errors++))
  fi
done

echo \"\"
echo \"Checking brew packages...\"
eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"
for pkg in neovim starship gh yazi lazydocker uv antidote gnupg; do
  if brew list 2>/dev/null | grep -q \"^\${pkg}\$\"; then
    echo \"  ✓ \$pkg\"
  else
    echo \"  ✗ \$pkg MISSING\"
    ((errors++))
  fi
done

echo \"\"
echo \"Checking apt packages...\"
for pkg in ripgrep fzf fd-find delta zoxide; do
  if dpkg -l 2>/dev/null | grep -q \"^ii.*\${pkg}\"; then
    echo \"  ✓ \$pkg\"
  else
    echo \"  ✗ \$pkg MISSING\"
    ((errors++))
  fi
done

echo \"\"
echo \"Checking external repos...\"
if [ -d .config/nvim ]; then
  echo \"  ✓ nvim config cloned\"
else
  echo \"  ✗ nvim config MISSING\"
  ((errors++))
fi

if [ \$errors -eq 0 ]; then
  echo \"\"
  echo \"🎉 ALL TESTS PASSED!\"
else
  echo \"\"
  echo \"❌ \$errors TEST(S) FAILED\"
fi

exit \$errors
'
"

exit $?