# Dotfiles - Powered by Chezmoi

## Installation

### Prerequisites

Before running the install script, ensure `curl` and `git` are installed on your system:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install -y curl git
```

### Quick Install

To install the dotfiles, execute the provided `install.sh` script.
```bash
./install.sh
```
Then follow the instructions.

## Brew Packages
* Brew packages are installed in the script `run_onchange_install-packages.sh.tmpl`
* Define list of packages in `.chezmoidata/packages.yaml`
* This script is executed when executing `chezmoi apply` if there is a change in the files.
* The script handles both macOS (via Homebrew) and Linux (via Linuxbrew) installations.

## Testing

We provide comprehensive testing for the dotfiles installation to ensure it works correctly on both Linux and macOS.

### Local Testing (Linux via Docker)

Run the integration test locally to verify the Linux installation works correctly:

```bash
./tests/integration-test.sh
```

This script will:
1. Pull Ubuntu 24.04 (latest LTS) Docker image
2. Create an isolated test environment
3. Run the full dotfiles installation
4. Verify all components are installed correctly:
   - Homebrew (Linuxbrew)
   - Chezmoi
   - Dotfiles (.zshrc, .tmux.conf, .gitconfig, etc.)
   - Apt packages (ripgrep, fzf, fd-find, delta, zoxide, etc.)
   - Brew packages (nvim, starship, gh, lazydocker, yazi, uv, antidote, gnupg)
   - External repos (.config/nvim)

**Requirements:**
- Docker installed and running
- Internet connection

**Exit codes:**
- `0` - All tests passed
- `1` - One or more tests failed

### CI/CD Testing

Automated tests run on every push and pull request via GitHub Actions:

![Test Status](https://github.com/JadHADDAD92/dotfiles/workflows/Test%20Dotfiles%20Installation/badge.svg)

**Test Matrix:**
- **Linux:** Ubuntu 24.04 (x64)
- **macOS:** macOS 26 (Tahoe) on Apple Silicon (ARM64)

Both environments are tested with strict validation - any missing component will cause the test to fail.

### Manual Testing

To test manually on a fresh system:

```bash
# Clone the repository (or download install.sh)
git clone https://github.com/JadHADDAD92/dotfiles.git
cd dotfiles

# Run the installer
./install.sh
```

For non-interactive environments (CI, Docker), set these environment variables:
```bash
export NONINTERACTIVE=1
export CI=true
./install.sh
```

## ZSH Plugins
* Plugins are installed and loaded in the ~/.zshrc by executing `antidote load`.
* Define list of plugins in `dot_zsh_plugins.txt` file.
