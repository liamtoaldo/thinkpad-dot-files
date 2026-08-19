# Dotfiles

System configurations based on i3 and Polybar, structured for use with GNU Stow.

## Requirements

Make sure to install the necessary packages based on your distribution.

**Arch Linux:**
```bash
sudo pacman -S i3-wm polybar neovim rofi dunst picom stow kitty htop flameshot autorandr tlp
```

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install i3 polybar neovim rofi dunst picom stow kitty htop flameshot autorandr tlp
```

**Fedora:**
```bash
sudo dnf install i3 polybar neovim rofi dunst picom stow kitty htop flameshot autorandr tlp
```

## Installation

1. Clone the repository:
```bash
git clone <REPO_URL> ~/dot-files
cd ~/dot-files
```

2. Create symbolic links using GNU Stow. Stow will link the files present in each folder directly into the user's home directory (e.g. `.config/`).
```bash
stow i3 polybar nvim rofi dunst picom kitty htop flameshot autorandr
```

3. TLP configs go into `/etc`, link them as root:
```bash
sudo stow -t / tlp
```

To remove the symbolic links:
```bash
stow -D i3 polybar nvim rofi dunst picom kitty htop flameshot autorandr
sudo stow -t / -D tlp
```
