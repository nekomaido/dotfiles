# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

- **Shell**: Zsh with Starship prompt, fzf, zoxide
- **Editor**: Neovim (Lazy.nvim, LSP, Telescope, Treesitter)
- **Terminal**: Kitty, Tmux
- **WM**: Niri, Waybar, Rofi (Linux only)
- **Tools**: Yazi, Lazygit, Lazydocker, MPV

Uses a custom "Noctalia" color theme across configs.

## Requirements

- chezmoi
- zsh, starship, fzf, zoxide, eza, bat
- neovim (0.9+)
- kitty, tmux

## Installation

```bash
# Install chezmoi and apply dotfiles
chezmoi init https://github.com/nekomaido/dotfiles.git
chezmoi apply
```

## Cross-Platform

Supports Linux and macOS. Platform-specific configs are handled via chezmoi templates:
- Niri/Waybar/Rofi are excluded on macOS
- Zsh plugins source from appropriate paths per OS
