# Neovim & Tmux Configuration Setup

This repository contains my personal configurations for **Neovim** (powered by `lazy.nvim`) and **Tmux** (powered by `TPM`). 

It includes an automated cross-platform installation script `setup.sh` that detects your OS, installs Neovim and Tmux, applies these configuration settings, and downloads the necessary plugins.

## 🚀 Quick Install

To quickly set up these configurations on a new machine, clone this repository and run the setup script:

```bash
git clone https://github.com/SaumyaBhandari/Nvim-and-Tmux-Setup.git
cd Nvim-and-Tmux-Setup
chmod +x setup.sh
./setup.sh
```

### Supported Operating Systems
- 🍎 **macOS** (via Homebrew)
- 🐧 **Linux** (Ubuntu, Debian, Arch Linux, Pop!_OS)
- 🪟 **Windows** (Skips native Tmux, installs Neovim via winget/chocolatey. WSL is fully supported via the Linux paths!)

---

## ⚡ Key Features & Keymaps

### 🎮 Neovim Setup (`lazy.nvim`)
Our Neovim configuration is structured in Lua and features a modular setup for plugins.

*   **Leader Key:** `<Space>`
*   **Window Splits:**
    *   `<Leader>v` - Split Vertically
    *   `<Leader>h` - Split Horizontally
    *   `<Leader>se` - Equal Split Sizes
    *   `<Leader>xs` - Close Current Split
*   **Buffer Management:**
    *   `<S-Tab>` - Previous Buffer
    *   `<Leader>x` - Close Current Buffer
    *   `<Leader>b` - Open New Empty Buffer
*   **Navigation:**
    *   `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` - Seamless Navigation between Neovim splits and Tmux panes (via `vim-tmux-navigator`)
*   **Resize Mode:**
    *   `<Leader>r` - Enter Resize Mode (Use arrow keys to resize splits, press `<Esc>` to exit)

### 📟 Tmux Setup (`tpm`)
*   **Prefix Key:** `Ctrl+a` (rebound from `Ctrl+b` for ergonomics)
*   **Configuration Reload:** `Prefix + r`
*   **Window Splits (in CWD):**
    *   `Prefix + V` - Horizontally (Vertical layout split)
    *   `Prefix + H` - Vertically (Horizontal layout split)
*   **Window Navigation:**
    *   `Prefix + c` - New Window (in current working directory)
    *   `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` - Seamless Navigation between Tmux panes and Neovim splits
*   **Vi Copy Mode:**
    *   `Prefix + [` - Enter Copy Mode
    *   `v` - Begin Selection (in copy mode)
    *   `y` - Copy Selection to system clipboard

---

## 📦 Installed Plugins

### Neovim Plugins
- `neo-tree.nvim` - Directory tree
- `telescope.nvim` - Fuzzy finder
- `nvim-treesitter` - Advanced syntax highlighting
- `nvim-lspconfig` + Mason - LSP package manager and configurations
- `nvim-cmp` - Autocompletion engine
- `bufferline.nvim` + `lualine.nvim` - Sleek status and tab bars
- `vim-tmux-navigator` - Seamless Tmux and Vim pane switching
- `gitsigns.nvim` - Git integration in signs column
- `avante.nvim` - AI assistant in Neovim

### Tmux Plugins
- `tpm` - Tmux Plugin Manager
- `christoomey/vim-tmux-navigator` - Navigate smoothly across Tmux panes & Vim windows
- `tmux-plugins/tmux-resurrect` - Save and restore Tmux sessions
- `tmux-plugins/tmux-continuum` - Auto-save sessions
- `hendrikmi/tmux-cpu-mem-monitor` - CPU & Memory status in the bar
