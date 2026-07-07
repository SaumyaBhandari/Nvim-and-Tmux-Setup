#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helpers for logging
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}
error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Ensure script is run from its own directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect Operating System
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "mac"
            ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian|pop)
                        echo "ubuntu"
                        ;;
                    arch|manjaro)
                        echo "arch"
                        ;;
                    *)
                        if command -v apt-get &>/dev/null; then
                            echo "ubuntu"
                        elif command -v pacman &>/dev/null; then
                            echo "arch"
                        else
                            echo "linux-generic"
                        fi
                        ;;
                esac
            else
                echo "linux-generic"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            if [[ "${OS:-}" == *"Windows"* ]]; then
                echo "windows"
            else
                echo "unknown"
            fi
            ;;
    esac
}

OS=$(detect_os)
info "Detected OS: $OS"

# Install Neovim and Tmux based on OS
install_dependencies() {
    case "$OS" in
        mac)
            info "Installing dependencies on macOS using Homebrew..."
            if ! command -v brew &>/dev/null; then
                info "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add brew to PATH for current execution
                if [ -d "/opt/homebrew/bin" ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [ -d "/usr/local/bin" ]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            brew update
            brew install neovim tmux git curl
            ;;
        ubuntu)
            info "Installing dependencies on Ubuntu/Debian via apt..."
            sudo apt-get update
            sudo apt-get install -y neovim tmux git curl
            ;;
        arch)
            info "Installing dependencies on Arch Linux via pacman..."
            sudo pacman -Syu --noconfirm neovim tmux git curl
            ;;
        windows)
            info "Detected Windows (Git Bash/WSL/Native)."
            if command -v winget &>/dev/null; then
                info "Installing Neovim via winget..."
                winget install Neovim.Neovim --silent --accept-source-agreement --accept-package-agreements || true
            elif command -v choco &>/dev/null; then
                info "Installing Neovim via chocolatey..."
                choco install neovim -y || true
            else
                warn "Could not find winget or choco. Please install Neovim manually."
            fi
            warn "Note: Tmux is not natively supported on Windows. If you are using WSL, please run this script inside the WSL terminal (which will run the Linux installer)."
            ;;
        *)
            error "Unsupported OS. Please install neovim, tmux, git, and curl manually."
            exit 1
            ;;
    esac
}

# Apply configurations
apply_config() {
    # 1. Neovim config
    info "Applying Neovim configuration..."
    NVIM_CONF_DIR="${HOME}/.config/nvim"
    if [ -d "$NVIM_CONF_DIR" ]; then
        BACKUP_DIR="${NVIM_CONF_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        info "Existing Neovim configuration found at $NVIM_CONF_DIR. Backing up to $BACKUP_DIR..."
        mv "$NVIM_CONF_DIR" "$BACKUP_DIR"
    fi
    mkdir -p "${HOME}/.config"
    cp -R "${SCRIPT_DIR}/nvim" "$NVIM_CONF_DIR"
    success "Neovim configuration applied."

    # 2. Tmux config
    info "Applying Tmux configuration..."
    TMUX_CONF_DIR="${HOME}/.config/tmux"
    if [ -d "$TMUX_CONF_DIR" ]; then
        BACKUP_DIR="${TMUX_CONF_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        info "Existing Tmux configuration found at $TMUX_CONF_DIR. Backing up to $BACKUP_DIR..."
        mv "$TMUX_CONF_DIR" "$BACKUP_DIR"
    fi
    cp -R "${SCRIPT_DIR}/tmux" "$TMUX_CONF_DIR"
    success "Tmux configuration applied."

    # Install Tmux Plugin Manager (TPM)
    TPM_DIR="${HOME}/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        success "TPM installed."
    else
        info "Tmux Plugin Manager already installed. Updating..."
        (cd "$TPM_DIR" && git pull)
    fi

    # Install Tmux plugins using TPM's script
    info "Installing Tmux plugins..."
    if command -v tmux &>/dev/null; then
        # Start a dummy tmux session in the background to allow tpm to install plugins
        tmux new-session -d -s temp_tpm_install || true
        # Run install_plugins script
        "${TPM_DIR}/bin/install_plugins" || true
        # Kill the dummy session
        tmux kill-session -t temp_tpm_install || true
        success "Tmux plugins installed."
    else
        warn "Tmux not found. Skipping automatic plugin installation."
    fi

    # Pre-sync Lazy.nvim plugins
    if command -v nvim &>/dev/null; then
        info "Pre-syncing Neovim plugins (Lazy)..."
        nvim --headless "+Lazy! sync" +qa || true
        success "Neovim plugins synchronized."
    fi
}

# Main Execution Flow
install_dependencies
apply_config

info "Reloading/Restarting terminal session settings..."
# Source the zshrc if we are in zsh, or bashrc if in bash to refresh aliases
if [ -n "${SHELL:-}" ]; then
    SHELL_NAME=$(basename "$SHELL")
    if [ "$SHELL_NAME" = "zsh" ] && [ -f "${HOME}/.zshrc" ]; then
        info "To refresh your current zsh session, run: source ~/.zshrc"
    elif [ "$SHELL_NAME" = "bash" ] && [ -f "${HOME}/.bashrc" ]; then
        info "To refresh your current bash session, run: source ~/.bashrc"
    fi
fi

# Reload tmux server if running
if pgrep tmux &>/dev/null; then
    info "Tmux is running. Reloading tmux configuration..."
    tmux source-file "${HOME}/.config/tmux/tmux.conf" 2>/dev/null || true
fi

success "Setup complete! You can now start using Neovim and Tmux."
info "Try launching 'nvim' or starting a new 'tmux' session to see your new configuration!"
