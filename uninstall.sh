#!/usr/bin/env bash
# Bureau — Uninstall script
# This removes Bureau customisations but leaves installed apps intact.

set -euo pipefail

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${RED}"
echo '  Bureau Uninstaller'
echo -e "${NC}"
echo ""
echo -e "${YELLOW}This will remove:${NC}"
echo "  - Bureau theme (GTK CSS overrides)"
echo "  - Bureau wallpapers"
echo "  - Bureau helper commands (bureau, bureau-ask)"
echo "  - Bureau config files"
echo "  - Starship prompt config"
echo "  - Bureau aliases from .bashrc"
echo ""
echo -e "${YELLOW}This will NOT remove:${NC}"
echo "  - Installed apps (GIMP, Inkscape, Chrome, etc.)"
echo "  - Installed fonts"
echo "  - GNOME extensions"
echo "  - Flatpak apps"
echo ""
read -p "Continue with uninstall? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Remove theme
echo -e "${YELLOW}▸${NC} Removing Bureau theme..."
rm -f "$HOME/.config/gtk-4.0/gtk.css"
rm -f "$HOME/.config/gtk-3.0/gtk.css"
gsettings reset org.gnome.desktop.interface color-scheme
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.interface document-font-name
gsettings reset org.gnome.desktop.interface monospace-font-name
echo -e "${BLUE}✓${NC} Theme reset to defaults"

# Remove wallpapers
echo -e "${YELLOW}▸${NC} Removing Bureau wallpapers..."
rm -rf "$HOME/.local/share/backgrounds/bureau"
gsettings reset org.gnome.desktop.background picture-uri
gsettings reset org.gnome.desktop.background picture-uri-dark
echo -e "${BLUE}✓${NC} Wallpapers removed"

# Remove Bureau commands
echo -e "${YELLOW}▸${NC} Removing Bureau commands..."
rm -f "$HOME/.local/bin/bureau"
rm -f "$HOME/.local/bin/bureau-ask"
echo -e "${BLUE}✓${NC} Commands removed"

# Remove Bureau config
echo -e "${YELLOW}▸${NC} Removing Bureau config..."
rm -rf "$HOME/.config/bureau"
echo -e "${BLUE}✓${NC} Config removed"

# Remove Starship config
echo -e "${YELLOW}▸${NC} Removing Starship config..."
rm -f "$HOME/.config/starship.toml"
echo -e "${BLUE}✓${NC} Starship config removed"

# Clean .bashrc (remove Bureau section)
echo -e "${YELLOW}▸${NC} Cleaning .bashrc..."
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/# Bureau Aliases/,/# End Bureau/d' "$HOME/.bashrc" 2>/dev/null || true
    sed -i '/starship init bash/d' "$HOME/.bashrc" 2>/dev/null || true
    sed -i '/ANTHROPIC_API_KEY/d' "$HOME/.bashrc" 2>/dev/null || true
fi
echo -e "${BLUE}✓${NC} .bashrc cleaned"

# Remove desktop entries
echo -e "${YELLOW}▸${NC} Removing Bureau desktop entries..."
rm -f "$HOME/.local/share/applications/bureau-claude.desktop"
rm -f "$HOME/.local/share/applications/bureau-figma.desktop"
echo -e "${BLUE}✓${NC} Desktop entries removed"

echo ""
echo -e "${BLUE}Bureau has been uninstalled.${NC}"
echo "Installed apps and fonts remain — remove them manually if needed."
echo "Restart your session to fully apply changes."
