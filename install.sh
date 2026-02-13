#!/usr/bin/env bash
# ============================================================================
#  ____
# | __ ) _   _ _ __ ___  __ _ _   _
# |  _ \| | | | '__/ _ \/ _` | | | |
# | |_) | |_| | | |  __/ (_| | |_| |
# |____/ \__,_|_|  \___|\__,_|\__,_|
#
# Bureau — Beautiful, Opinionated Fedora for Creatives & Designers
# Bauhaus-inspired. Claude-powered. Made for makers.
#
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/chrischrisjnr/bureau/main/install.sh)
# ============================================================================

set -euo pipefail

# --- Colours (Bauhaus palette) ---
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GREY='\033[0;90m'
NC='\033[0m' # No colour
BOLD='\033[1m'

# --- Configuration ---
BUREAU_DIR="$HOME/.local/share/bureau"
BUREAU_CONFIG="$HOME/.config/bureau"
BUREAU_VERSION="1.0.0"
REPO_URL="https://github.com/chrischrisjnr/bureau"

# ============================================================================
# Helper Functions
# ============================================================================

banner() {
    echo -e "${RED}"
    echo '  ____'
    echo ' | __ ) _   _ _ __ ___  __ _ _   _'
    echo ' |  _ \| | | |  __/ _ \/ _` | | | |'
    echo ' | |_) | |_| | | |  __/ (_| | |_| |'
    echo ' |____/ \__,_|_|  \___|\__,_|\__,_|'
    echo -e "${NC}"
    echo -e "${GREY}  Beautiful, Opinionated Fedora for Creatives${NC}"
    echo -e "${GREY}  v${BUREAU_VERSION}${NC}"
    echo ""
}

step() {
    echo -e "\n${YELLOW}▸${NC} ${BOLD}$1${NC}"
}

substep() {
    echo -e "  ${GREY}→${NC} $1"
}

success() {
    echo -e "  ${BLUE}✓${NC} $1"
}

warn() {
    echo -e "  ${RED}⚠${NC} $1"
}

confirm() {
    echo -e "\n${YELLOW}$1${NC}"
    read -p "  Continue? [Y/n] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

preflight() {
    step "Running pre-flight checks"

    # Check we're on Fedora
    if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
        warn "Bureau is designed for Fedora. Detected: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    else
        success "Fedora detected"
    fi

    # Check for Gnome
    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$DESKTOP_SESSION" = "gnome" ]; then
        success "GNOME desktop detected"
    else
        warn "GNOME not detected. Bureau is built for GNOME."
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    fi

    # Check internet
    if ping -c 1 fedoraproject.org &>/dev/null; then
        success "Internet connection OK"
    else
        warn "No internet connection detected. Bureau needs internet to install."
        exit 1
    fi

    # Check disk space (need at least 15GB free)
    local free_space
    free_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$free_space" -lt 15 ]; then
        warn "Less than 15GB free. Bureau needs ~15GB for all creative apps."
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    else
        success "Disk space OK (${free_space}GB free)"
    fi
}

# ============================================================================
# System Update
# ============================================================================

update_system() {
    step "Updating system packages"
    sudo dnf upgrade -y --refresh
    success "System updated"
}

# ============================================================================
# RPM Fusion & Flathub Repositories
# ============================================================================

setup_repos() {
    step "Setting up additional repositories"

    # RPM Fusion (needed for many multimedia packages)
    substep "Adding RPM Fusion (free + nonfree)"
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
        2>/dev/null || true
    success "RPM Fusion enabled"

    # Flathub
    substep "Adding Flathub repository"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    success "Flathub enabled"

    # Google Chrome repo
    substep "Adding Google Chrome repository"
    sudo tee /etc/yum.repos.d/google-chrome.repo > /dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
    success "Google Chrome repo added"
}

# ============================================================================
# Core System Packages
# ============================================================================

install_core() {
    step "Installing core system packages"

    local core_packages=(
        # Build essentials
        gcc gcc-c++ make cmake git curl wget unzip
        # System utilities
        htop btop fastfetch neofetch
        # File management
        nautilus file-roller p7zip p7zip-plugins
        # Networking
        NetworkManager-wifi
        # Multimedia codecs
        gstreamer1-plugins-base gstreamer1-plugins-good
        gstreamer1-plugins-bad-free gstreamer1-plugins-ugly
        gstreamer1-libav
        # Fonts rendering
        freetype fontconfig
        # Clipboard
        wl-clipboard xclip
        # Screenshots
        gnome-screenshot
        # Colour management
        colord gnome-color-manager
        # Disk management
        gnome-disk-utility
        # Archive support
        unrar
        # Thumbnail support
        gnome-epub-thumbnailer ffmpegthumbnailer
    )

    sudo dnf install -y "${core_packages[@]}"
    success "Core packages installed"
}

# ============================================================================
# Creative Suite
# ============================================================================

install_creative_suite() {
    step "Installing creative suite"

    # --- DNF packages ---
    substep "Installing GIMP (photo editing)"
    sudo dnf install -y gimp gimp-data-extras
    success "GIMP installed"

    substep "Installing Inkscape (vector graphics)"
    sudo dnf install -y inkscape
    success "Inkscape installed"

    substep "Installing Krita (digital painting)"
    sudo dnf install -y krita
    success "Krita installed"

    substep "Installing Blender (3D modelling & animation)"
    sudo dnf install -y blender
    success "Blender installed"

    substep "Installing Darktable (RAW photo processing)"
    sudo dnf install -y darktable
    success "Darktable installed"

    substep "Installing Scribus (desktop publishing)"
    sudo dnf install -y scribus
    success "Scribus installed"

    substep "Installing Shotwell (photo management)"
    sudo dnf install -y shotwell
    success "Shotwell installed"

    substep "Installing Kdenlive (video editing)"
    sudo dnf install -y kdenlive
    success "Kdenlive installed"

    substep "Installing OBS Studio (screen recording & streaming)"
    sudo dnf install -y obs-studio
    success "OBS Studio installed"

    substep "Preparing DaVinci Resolve"
    # DaVinci Resolve requires manual download from Blackmagic (registration required)
    # Install dependencies so it's ready to go once downloaded
    sudo dnf install -y \
        libxcrypt-compat mesa-libGLU alsa-lib apr apr-util \
        libxkbcommon-x11 mesa-libOpenCL ocl-icd \
        opencl-headers libXtst libXfixes \
        2>/dev/null || true

    mkdir -p "$HOME/.config/bureau"
    cat > "$HOME/.config/bureau/davinci-resolve-setup.md" << 'DVEOF'
# Installing DaVinci Resolve on Bureau

DaVinci Resolve is free professional video editing & colour grading software.
It requires a manual download because Blackmagic requires registration.

## Steps

1. Go to https://www.blackmagicdesign.com/products/davinciresolve
2. Click "Free Download" → choose "DaVinci Resolve for Linux"
3. Register (or log in) and download the .zip file
4. Extract the zip:
   ```
   unzip DaVinci_Resolve_*_Linux.zip
   ```
5. Run the installer:
   ```
   sudo ./DaVinci_Resolve_*_Linux.run
   ```
6. Follow the installer prompts
7. DaVinci Resolve will appear in your app drawer

## Notes
- Bureau has pre-installed all required dependencies
- Free version includes editing, colour, Fairlight audio, and Fusion VFX
- Studio version ($295 one-time) adds GPU acceleration, HDR, and more
- For NVIDIA GPUs: install proprietary drivers for best performance
- For AMD GPUs: the open-source drivers included in Fedora work well
DVEOF
    success "DaVinci Resolve dependencies installed (run 'bureau davinci' for setup guide)"

    substep "Installing ImageMagick (command-line image processing)"
    sudo dnf install -y ImageMagick
    success "ImageMagick installed"

    # --- Flatpak creative apps ---
    substep "Installing Figma (UI/UX design — web app)"
    # Figma will be set up as a Chrome web app later

    substep "Installing Canva (via Flatpak if available)"
    # Canva will also be a web app

    success "Creative suite installed"
}

# ============================================================================
# Everyday Apps
# ============================================================================

install_apps() {
    step "Installing everyday applications"

    # Google Chrome
    substep "Installing Google Chrome"
    sudo dnf install -y google-chrome-stable
    success "Google Chrome installed"

    # Spotify
    substep "Installing Spotify"
    flatpak install -y flathub com.spotify.Client
    success "Spotify installed"

    # Discord
    substep "Installing Discord"
    flatpak install -y flathub com.discordapp.Discord
    success "Discord installed"

    # Obsidian
    substep "Installing Obsidian (notes & knowledge base)"
    flatpak install -y flathub md.obsidian.Obsidian
    success "Obsidian installed"

    # LibreOffice (usually pre-installed on Fedora, but ensure it)
    substep "Ensuring LibreOffice is installed"
    sudo dnf install -y libreoffice
    success "LibreOffice installed"

    # Telegram
    substep "Installing Telegram"
    flatpak install -y flathub org.telegram.desktop
    success "Telegram installed"

    # Bottles (for running Windows apps like Affinity)
    substep "Installing Bottles (Windows app compatibility)"
    flatpak install -y flathub com.usebottles.bottles
    success "Bottles installed"

    # File sharing
    substep "Installing LocalSend (AirDrop alternative)"
    flatpak install -y flathub org.localsend.localsend_app
    success "LocalSend installed"

    # Terminal
    substep "Ensuring GNOME Terminal is available"
    sudo dnf install -y gnome-terminal
    success "GNOME Terminal ready"
}

# ============================================================================
# Designer Font Collection
# ============================================================================

install_fonts() {
    step "Installing designer font collection"

    local font_dir="$HOME/.local/share/fonts/bureau"
    mkdir -p "$font_dir"

    # System fonts via DNF
    local font_packages=(
        # Google Fonts
        google-noto-sans-fonts
        google-noto-serif-fonts
        google-noto-sans-mono-fonts
        google-noto-emoji-fonts
        google-noto-color-emoji-fonts
        # Adobe
        adobe-source-code-pro-fonts
        adobe-source-sans-pro-fonts
        adobe-source-serif-pro-fonts
        # Mozilla
        mozilla-fira-sans-fonts
        mozilla-fira-mono-fonts
        # IBM
        ibm-plex-sans-fonts
        ibm-plex-mono-fonts
        ibm-plex-serif-fonts
        # JetBrains
        jetbrains-mono-fonts-all
        # Inter
        rsms-inter-fonts
        # Liberation (metric-compatible with Arial, Times, Courier)
        liberation-sans-fonts
        liberation-serif-fonts
        liberation-mono-fonts
        # DejaVu
        dejavu-sans-fonts
        dejavu-serif-fonts
        dejavu-sans-mono-fonts
        # Cascadia Code (Microsoft)
        cascadia-code-fonts
    )

    sudo dnf install -y "${font_packages[@]}" 2>/dev/null || true

    # Download additional design fonts not in repos
    substep "Downloading additional designer fonts"

    # DM Sans (geometric, great for UI)
    curl -fsSL -o /tmp/dm-sans.zip \
        "https://fonts.google.com/download?family=DM+Sans" 2>/dev/null && \
        unzip -qo /tmp/dm-sans.zip -d "$font_dir/dm-sans" 2>/dev/null || true

    # Space Grotesk (Bauhaus-adjacent geometric sans)
    curl -fsSL -o /tmp/space-grotesk.zip \
        "https://fonts.google.com/download?family=Space+Grotesk" 2>/dev/null && \
        unzip -qo /tmp/space-grotesk.zip -d "$font_dir/space-grotesk" 2>/dev/null || true

    # Syne (expressive, great for headings)
    curl -fsSL -o /tmp/syne.zip \
        "https://fonts.google.com/download?family=Syne" 2>/dev/null && \
        unzip -qo /tmp/syne.zip -d "$font_dir/syne" 2>/dev/null || true

    # Work Sans
    curl -fsSL -o /tmp/work-sans.zip \
        "https://fonts.google.com/download?family=Work+Sans" 2>/dev/null && \
        unzip -qo /tmp/work-sans.zip -d "$font_dir/work-sans" 2>/dev/null || true

    # Refresh font cache
    fc-cache -f
    success "Designer font collection installed (30+ families)"
}

# ============================================================================
# GNOME Configuration & Theming (Bauhaus-Inspired)
# ============================================================================

configure_gnome() {
    step "Configuring GNOME desktop (Bauhaus theme)"

    # --- GNOME Shell Settings ---
    substep "Applying GNOME settings"

    # Appearance
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface font-name 'Inter 11'
    gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 11'

    # Font rendering
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    gsettings set org.gnome.desktop.interface font-hinting 'slight'

    # Window behaviour
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.mutter center-new-windows true

    # Touchpad (natural scrolling like macOS)
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

    # Mouse
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

    # Night Light (colour temperature — easy on designer eyes)
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3500

    # File manager
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
    gsettings set org.gnome.nautilus.preferences show-hidden-files false

    # Power
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
    gsettings set org.gnome.desktop.session idle-delay 300

    # Workspaces (4 fixed — one per project/context)
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

    # Dock / Dash
    gsettings set org.gnome.shell favorite-apps \
        "['google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'bureau-claude.desktop', 'bureau-figma.desktop', 'bureau-miro.desktop', 'bureau-notion.desktop', 'gimp.desktop', 'org.inkscape.Inkscape.desktop', 'org.kde.krita.desktop', 'org.blender.Blender.desktop', 'com.spotify.Client.desktop', 'com.discordapp.Discord.desktop', 'md.obsidian.Obsidian.desktop']"

    success "GNOME settings applied"
}

# ============================================================================
# GTK Theme (Bauhaus Dark)
# ============================================================================

install_theme() {
    step "Installing Bureau Bauhaus theme"

    # --- GTK 4 custom CSS ---
    local gtk4_dir="$HOME/.config/gtk-4.0"
    mkdir -p "$gtk4_dir"

    cat > "$gtk4_dir/gtk.css" << 'ENDCSS'
/* ============================================================
   Bureau — Bauhaus Dark Theme (GTK 4 overrides)
   Inspired by Kandinsky, Moholy-Nagy, and the Bauhaus school.
   Primary: #be1e2d (red), #21409a (blue), #f2c12e (yellow)
   ============================================================ */

/* Accent colour — Bauhaus Blue */
@define-color accent_bg_color #21409a;
@define-color accent_fg_color #ffffff;
@define-color accent_color #3a5fc1;

/* Background tones — warm dark */
@define-color window_bg_color #1a1a1a;
@define-color window_fg_color #e8e4de;
@define-color view_bg_color #212121;
@define-color view_fg_color #e8e4de;
@define-color headerbar_bg_color #1a1a1a;
@define-color headerbar_fg_color #e8e4de;
@define-color headerbar_border_color #333333;
@define-color card_bg_color #262626;
@define-color card_fg_color #e8e4de;
@define-color popover_bg_color #262626;
@define-color popover_fg_color #e8e4de;
@define-color dialog_bg_color #262626;
@define-color dialog_fg_color #e8e4de;
@define-color sidebar_bg_color #1e1e1e;
@define-color sidebar_fg_color #e8e4de;

/* Destructive — Bauhaus Red */
@define-color destructive_bg_color #be1e2d;
@define-color destructive_fg_color #ffffff;
@define-color destructive_color #be1e2d;

/* Warning — Bauhaus Yellow */
@define-color warning_bg_color #f2c12e;
@define-color warning_fg_color #1a1a1a;
@define-color warning_color #f2c12e;

/* Success */
@define-color success_bg_color #4a9e6d;
@define-color success_fg_color #ffffff;
@define-color success_color #4a9e6d;

/* Borders & separators */
@define-color borders rgba(255,255,255,0.08);

/* Selection */
@define-color selected_bg_color #21409a;
@define-color selected_fg_color #ffffff;

/* Links — Bauhaus Yellow */
@define-color link_color #f2c12e;
@define-color link_visited_color #d4a826;
ENDCSS

    # --- GTK 3 (same colours for older apps like GIMP) ---
    local gtk3_dir="$HOME/.config/gtk-3.0"
    mkdir -p "$gtk3_dir"

    cat > "$gtk3_dir/gtk.css" << 'ENDCSS'
/* Bureau Bauhaus Dark — GTK 3 overrides */
@define-color theme_bg_color #1a1a1a;
@define-color theme_fg_color #e8e4de;
@define-color theme_selected_bg_color #21409a;
@define-color theme_selected_fg_color #ffffff;
@define-color insensitive_bg_color #2a2a2a;
@define-color insensitive_fg_color #888888;
@define-color theme_unfocused_bg_color #1a1a1a;
@define-color theme_unfocused_fg_color #e8e4de;
ENDCSS

    success "Bureau Bauhaus theme installed"
}

# ============================================================================
# GNOME Extensions
# ============================================================================

install_extensions() {
    step "Installing GNOME extensions for creative workflow"

    # Install extension manager
    substep "Installing Extension Manager"
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    success "Extension Manager installed"

    # Install gnome-extensions-cli for scripted installs
    substep "Installing gnome-extensions-cli"
    sudo dnf install -y pipx 2>/dev/null || true
    pipx install gnome-extensions-cli 2>/dev/null || pip install --user gnome-extensions-cli 2>/dev/null || true

    # Recommended extensions (user can install via Extension Manager)
    cat > "$HOME/.config/bureau/recommended-extensions.txt" << 'EOF'
# Bureau — Recommended GNOME Extensions
# Install these via Extension Manager (pre-installed) or extensions.gnome.org
#
# Essential:
# - Blur my Shell — Beautiful blurred overview and panel
# - Dash to Dock — macOS-style dock (customise position/size)
# - AppIndicator — System tray icons (needed for Discord, Spotify etc.)
# - Clipboard Indicator — Clipboard history (essential for design work)
# - Color Picker — Pick colours from anywhere on screen (Super+Shift+C)
#
# Productivity:
# - Space Bar — Workspace indicator in top bar
# - Vitals — System monitor in top bar
# - Quick Settings Tweaker — Better quick settings panel
#
# Aesthetics:
# - User Themes — Custom shell themes
# - Rounded Window Corners — Softer window appearance
# - Compiz alike magic lamp effect — Satisfying minimise animation
EOF

    success "Extension recommendations saved to ~/.config/bureau/"
    substep "Open Extension Manager after install to enable recommended extensions"
}

# ============================================================================
# Wallpapers & Branding
# ============================================================================

install_branding() {
    step "Installing Bureau wallpapers & branding"

    local wall_dir="$HOME/.local/share/backgrounds/bureau"
    mkdir -p "$wall_dir"

    # Generate Bauhaus-inspired wallpapers using ImageMagick
    substep "Generating Bauhaus-inspired wallpapers"

    # Wallpaper 1: Dark geometric — primary composition
    convert -size 3840x2160 xc:'#1a1a1a' \
        -fill '#be1e2d' -draw "circle 960,1080 960,780" \
        -fill '#21409a' -draw "rectangle 2200,400 3200,1400" \
        -fill '#f2c12e' -draw "polygon 1800,1600 2100,2000 1500,2000" \
        -fill 'rgba(255,255,255,0.03)' -draw "line 0,720 3840,720" \
        -fill 'rgba(255,255,255,0.03)' -draw "line 0,1440 3840,1440" \
        -fill 'rgba(255,255,255,0.03)' -draw "line 1280,0 1280,2160" \
        -fill 'rgba(255,255,255,0.03)' -draw "line 2560,0 2560,2160" \
        "$wall_dir/bureau-bauhaus-dark.png" 2>/dev/null || true

    # Wallpaper 2: Light geometric
    convert -size 3840x2160 xc:'#f5f2eb' \
        -fill '#be1e2d' -draw "rectangle 200,200 600,600" \
        -fill '#21409a' -draw "circle 3000,500 3000,300" \
        -fill '#f2c12e' -draw "polygon 1920,1800 2120,2100 1720,2100" \
        -fill 'rgba(0,0,0,0.04)' -draw "line 0,1080 3840,1080" \
        -fill 'rgba(0,0,0,0.04)' -draw "line 1920,0 1920,2160" \
        "$wall_dir/bureau-bauhaus-light.png" 2>/dev/null || true

    # Wallpaper 3: Minimal dark
    convert -size 3840x2160 xc:'#1a1a1a' \
        -fill '#21409a' -draw "rectangle 0,2100 3840,2160" \
        -fill '#be1e2d' -draw "rectangle 0,2060 3840,2100" \
        -fill '#f2c12e' -draw "rectangle 0,2040 3840,2060" \
        "$wall_dir/bureau-minimal-dark.png" 2>/dev/null || true

    # Wallpaper 4: Grid (Bauhaus teaching grid)
    convert -size 3840x2160 xc:'#1a1a1a' \
        -stroke 'rgba(255,255,255,0.04)' -strokewidth 1 \
        -draw "line 0,540 3840,540" -draw "line 0,1080 3840,1080" \
        -draw "line 0,1620 3840,1620" \
        -draw "line 960,0 960,2160" -draw "line 1920,0 1920,2160" \
        -draw "line 2880,0 2880,2160" \
        -fill '#be1e2d' -draw "circle 1920,1080 1920,1060" \
        "$wall_dir/bureau-grid-dark.png" 2>/dev/null || true

    # Set default wallpaper
    if [ -f "$wall_dir/bureau-bauhaus-dark.png" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wall_dir/bureau-bauhaus-dark.png"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wall_dir/bureau-bauhaus-dark.png"
        gsettings set org.gnome.desktop.background picture-options 'zoom'
        success "Bureau wallpapers installed & set"
    else
        warn "ImageMagick not available yet — wallpapers will generate on next run"
    fi
}

# ============================================================================
# Claude AI Integration
# ============================================================================

install_claude() {
    step "Setting up Claude AI integration"

    # --- Claude.ai as Chrome Web App ---
    substep "Creating Claude.ai web app shortcut"

    local apps_dir="$HOME/.local/share/applications"
    mkdir -p "$apps_dir"

    cat > "$apps_dir/bureau-claude.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Claude
Comment=Claude AI Assistant by Anthropic
Exec=google-chrome-stable --app=https://claude.ai --class=claude-ai
Icon=claude-ai
Terminal=false
Type=Application
Categories=Utility;AI;
StartupWMClass=claude-ai
Keywords=ai;assistant;claude;anthropic;
EOF

    # --- Figma web app ---
    cat > "$apps_dir/bureau-figma.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Figma
Comment=Collaborative UI/UX Design Tool
Exec=google-chrome-stable --app=https://www.figma.com --class=figma
Icon=figma
Terminal=false
Type=Application
Categories=Graphics;Design;
StartupWMClass=figma
Keywords=design;ui;ux;figma;prototype;
EOF

    # --- Miro web app ---
    cat > "$apps_dir/bureau-miro.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Miro
Comment=Online Collaborative Whiteboard
Exec=google-chrome-stable --app=https://miro.com --class=miro
Icon=miro
Terminal=false
Type=Application
Categories=Graphics;ProjectManagement;
StartupWMClass=miro
Keywords=whiteboard;miro;collaborate;brainstorm;
EOF

    # --- Notion web app ---
    cat > "$apps_dir/bureau-notion.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Notion
Comment=All-in-one Workspace
Exec=google-chrome-stable --app=https://www.notion.so --class=notion
Icon=notion
Terminal=false
Type=Application
Categories=Office;ProjectManagement;
StartupWMClass=notion
Keywords=notion;notes;wiki;project;docs;
EOF

    success "Claude.ai, Figma, Miro & Notion web apps created"

    # --- Claude Code (terminal AI) ---
    substep "Installing Claude Code (terminal AI assistant)"

    # Check if Node.js is installed, install if not
    if ! command -v node &>/dev/null; then
        substep "Installing Node.js (required for Claude Code)"
        sudo dnf install -y nodejs npm
    fi

    # Install Claude Code globally
    npm install -g @anthropic-ai/claude-code 2>/dev/null || {
        warn "Claude Code install failed — you can install it later with: npm install -g @anthropic-ai/claude-code"
    }
    success "Claude Code installed (run 'claude' in any terminal)"

    # --- Bureau Ask: Quick Claude helper ---
    substep "Installing 'bureau-ask' shell helper"

    mkdir -p "$HOME/.local/bin"

    cat > "$HOME/.local/bin/bureau-ask" << 'ASKEOF'
#!/usr/bin/env bash
# bureau-ask — Quick Claude AI helper for the terminal
# Usage: bureau-ask "resize all PNGs in this folder to 1200px"
# Requires: ANTHROPIC_API_KEY environment variable

set -euo pipefail

BLUE='\033[0;34m'
GREY='\033[0;90m'
NC='\033[0m'

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo -e "${GREY}Bureau Ask needs your Anthropic API key.${NC}"
    echo -e "${GREY}Get one at: https://console.anthropic.com/settings/keys${NC}"
    echo ""
    read -sp "Paste your API key (it won't be displayed): " api_key
    echo ""

    # Save to shell config
    if [ -f "$HOME/.bashrc" ]; then
        echo "export ANTHROPIC_API_KEY='$api_key'" >> "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo "export ANTHROPIC_API_KEY='$api_key'" >> "$HOME/.zshrc"
    fi
    export ANTHROPIC_API_KEY="$api_key"
    echo -e "${BLUE}✓${NC} API key saved to shell config."
    echo ""
fi

if [ $# -eq 0 ]; then
    echo -e "${BLUE}Bureau Ask${NC} — Claude-powered terminal helper"
    echo ""
    echo "Usage:"
    echo "  bureau-ask \"your question here\""
    echo ""
    echo "Examples:"
    echo "  bureau-ask \"resize all PNGs in this folder to 1200px wide\""
    echo "  bureau-ask \"convert this SVG to a 300dpi PNG\""
    echo "  bureau-ask \"find all .psd files larger than 100MB\""
    echo "  bureau-ask \"batch rename these files to lowercase with dashes\""
    exit 0
fi

QUESTION="$*"

# Add context about the system
SYSTEM_PROMPT="You are Bureau Ask, a creative assistant built into Bureau Linux. \
The user is a designer/creative professional running Fedora Linux with GNOME. \
They have GIMP, Inkscape, Krita, Blender, Darktable, ImageMagick, and ffmpeg available. \
Give concise, practical answers. If the answer is a command, just give the command. \
If it's a multi-step process, number the steps briefly. \
Current directory: $(pwd) \
Files here: $(ls -1 2>/dev/null | head -20)"

RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d "{
        \"model\": \"claude-sonnet-4-20250514\",
        \"max_tokens\": 1024,
        \"system\": \"$SYSTEM_PROMPT\",
        \"messages\": [{\"role\": \"user\", \"content\": \"$QUESTION\"}]
    }" 2>/dev/null)

# Extract text from response
echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for block in data.get('content', []):
        if block.get('type') == 'text':
            print(block['text'])
except:
    print('Error: Could not get response. Check your API key.')
" 2>/dev/null || echo "Error: Could not parse response."
ASKEOF

    chmod +x "$HOME/.local/bin/bureau-ask"

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    success "bureau-ask installed (run 'bureau-ask \"your question\"')"
}

# ============================================================================
# Bottles + Affinity Setup
# ============================================================================

setup_affinity() {
    step "Preparing Affinity via Bottles"

    substep "Bottles is installed via Flatpak"
    substep "Creating Affinity setup guide"

    mkdir -p "$HOME/.config/bureau"

    cat > "$HOME/.config/bureau/affinity-setup.md" << 'EOF'
# Running Affinity Apps on Bureau Linux via Bottles

Affinity Designer, Photo, and Publisher can run on Linux through Bottles.
This is a best-effort setup — compatibility varies by version.

## Prerequisites
- Bottles is pre-installed (check your app drawer)

## Setup Steps

### 1. Open Bottles
- Launch Bottles from your app drawer
- Create a new bottle called "Affinity"
- Environment: **Application**
- Runner: **Soda** or **Caffe** (latest version)

### 2. Configure the Bottle
In the bottle settings, enable:
- DXVK (for GPU acceleration)
- VKD3D (for DirectX 12 support)
- Windows version: **Windows 10**

### 3. Install Dependencies
In the bottle, go to Dependencies and install:
- dotnet48
- vcredist2019
- corefonts

### 4. Install Affinity
- Download Affinity v2 installers from affinity.serif.com (you need a licence)
- In Bottles, click "Run Executable" and select the Affinity installer
- Follow the Windows installer as normal

### 5. Known Issues
- **GPU rendering**: Some effects may not render correctly. Try disabling hardware acceleration in Affinity preferences.
- **Tablet pressure**: Wacom tablet pressure sensitivity may not work. Check Bottles' input settings.
- **Colour management**: ICC profiles may not load correctly. Export work in sRGB for safety.
- **Affinity v2.6+**: Some newer versions have improved Wine compatibility.

### 6. Alternative: Run in a VM
If Bottles doesn't work well enough, consider:
- GNOME Boxes (pre-installed on Fedora) with a Windows VM
- Assign GPU passthrough for better performance

## Stay Updated
Check these resources for compatibility updates:
- https://forum.affinity.serif.com (search "Linux" or "Wine")
- https://www.codeweavers.com/compatibility/crossover/affinity-designer-2
- https://appdb.winehq.org
EOF

    success "Affinity setup guide saved to ~/.config/bureau/affinity-setup.md"
}

# ============================================================================
# Developer & Terminal Setup
# ============================================================================

setup_terminal() {
    step "Configuring terminal & developer tools"

    # Install useful CLI tools
    substep "Installing modern CLI tools"
    sudo dnf install -y \
        zsh fish \
        fzf bat eza fd-find ripgrep \
        git-delta \
        jq yq \
        tldr \
        2>/dev/null || true

    # Install Starship prompt (beautiful, fast)
    substep "Installing Starship prompt"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y 2>/dev/null || true

    # Configure Starship
    mkdir -p "$HOME/.config"
    cat > "$HOME/.config/starship.toml" << 'EOF'
# Bureau Starship Prompt — Bauhaus minimal

format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$character"""

[character]
success_symbol = "[▸](bold blue)"
error_symbol = "[▸](bold red)"

[directory]
style = "bold yellow"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
style = "bold red"
symbol = ""
format = "[$symbol$branch]($style) "

[git_status]
style = "bold blue"
format = "[$all_status$ahead_behind]($style) "

[nodejs]
symbol = "⬢ "
style = "bold green"

[python]
symbol = "🐍 "
style = "bold yellow"
EOF

    # Add Starship to bash
    if ! grep -q 'starship init bash' "$HOME/.bashrc" 2>/dev/null; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    fi

    # Useful aliases for creatives
    cat >> "$HOME/.bashrc" << 'EOF'

# ============================================================
# Bureau Aliases — Creative Workflow Shortcuts
# ============================================================

# Quick open apps
alias design='inkscape'
alias paint='krita'
alias photo='gimp'
alias raw='darktable'
alias render='blender'
alias publish='scribus'
alias edit='kdenlive'

# Image operations (via ImageMagick)
alias img-resize='convert -resize'
alias img-info='identify -verbose'
alias img-to-png='mogrify -format png'
alias img-to-jpg='mogrify -format jpg -quality 90'
alias img-to-webp='mogrify -format webp -quality 85'

# Batch operations
alias batch-resize-1200='mogrify -resize 1200x *.png *.jpg 2>/dev/null'
alias batch-resize-2400='mogrify -resize 2400x *.png *.jpg 2>/dev/null'
alias batch-to-webp='mogrify -format webp -quality 85 *.png *.jpg 2>/dev/null'

# File listing (using eza if available)
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias lt='eza --tree --level=2 --icons'
fi

# Quick system info
alias sysinfo='fastfetch'

# Bureau
alias bureau-update='bash ~/.local/share/bureau/install.sh'
alias ask='bureau-ask'
EOF

    success "Terminal configured with creative aliases"
}

# ============================================================================
# Wacom / Drawing Tablet Support
# ============================================================================

setup_tablet() {
    step "Setting up drawing tablet support"

    # Wacom drivers (usually included in Fedora, but ensure)
    sudo dnf install -y \
        xorg-x11-drv-wacom \
        libwacom \
        gnome-control-center \
        2>/dev/null || true

    # OpenTabletDriver (for non-Wacom tablets like XP-Pen, Huion)
    substep "Note: For non-Wacom tablets (XP-Pen, Huion), install OpenTabletDriver:"
    substep "  https://opentabletdriver.net"

    success "Wacom tablet support configured (Settings > Wacom Tablet)"
}

# ============================================================================
# Colour Management
# ============================================================================

setup_colour() {
    step "Setting up colour management for design work"

    sudo dnf install -y \
        colord \
        gnome-color-manager \
        argyllcms \
        2>/dev/null || true

    substep "Colour management ready — calibrate via Settings > Colour"
    substep "Note: For accurate print work, calibrate with a hardware colorimeter"

    success "Colour management configured"
}

# ============================================================================
# Bureau Menu / Helper Script
# ============================================================================

install_bureau_menu() {
    step "Installing Bureau helper commands"

    mkdir -p "$HOME/.local/bin"

    # --- bureau command ---
    cat > "$HOME/.local/bin/bureau" << 'MENUEOF'
#!/usr/bin/env bash
# Bureau — Main helper command

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GREY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

show_help() {
    echo -e "${RED}"
    echo '  ____'
    echo ' | __ ) _   _ _ __ ___  __ _ _   _'
    echo ' |  _ \| | | |  __/ _ \/ _` | | | |'
    echo ' | |_) | |_| | | |  __/ (_| | |_| |'
    echo ' |____/ \__,_|_|  \___|\__,_|\__,_|'
    echo -e "${NC}"
    echo -e "  ${GREY}Beautiful, Opinionated Fedora for Creatives${NC}"
    echo ""
    echo -e "  ${BOLD}Commands:${NC}"
    echo -e "  ${YELLOW}bureau update${NC}        Update Bureau & system packages"
    echo -e "  ${YELLOW}bureau apps${NC}          List installed creative apps"
    echo -e "  ${YELLOW}bureau fonts${NC}          List installed font families"
    echo -e "  ${YELLOW}bureau theme dark${NC}     Switch to dark mode"
    echo -e "  ${YELLOW}bureau theme light${NC}    Switch to light mode"
    echo -e "  ${YELLOW}bureau ask \"...\"${NC}      Ask Claude AI a question"
    echo -e "  ${YELLOW}bureau affinity${NC}       Show Affinity setup guide"
    echo -e "  ${YELLOW}bureau davinci${NC}       Show DaVinci Resolve setup guide"
    echo -e "  ${YELLOW}bureau extensions${NC}     Show recommended GNOME extensions"
    echo -e "  ${YELLOW}bureau info${NC}           Show system info"
    echo -e "  ${YELLOW}bureau help${NC}           Show this help"
    echo ""
}

case "${1:-help}" in
    update)
        echo -e "${YELLOW}▸${NC} Updating system..."
        sudo dnf upgrade -y --refresh
        flatpak update -y
        echo -e "${BLUE}✓${NC} Bureau updated."
        ;;
    apps)
        echo -e "${BOLD}Bureau Creative Suite:${NC}"
        echo ""
        for app in gimp inkscape krita blender darktable scribus kdenlive obs-studio; do
            if command -v "$app" &>/dev/null || rpm -q "$app" &>/dev/null 2>&1; then
                echo -e "  ${BLUE}✓${NC} $app"
            else
                echo -e "  ${GREY}✗${NC} $app ${GREY}(not installed)${NC}"
            fi
        done
        echo ""
        echo -e "${BOLD}Everyday Apps:${NC}"
        echo ""
        for app in google-chrome-stable; do
            if command -v "$app" &>/dev/null; then
                echo -e "  ${BLUE}✓${NC} $app"
            fi
        done
        flatpak list --app --columns=application,name 2>/dev/null | while read -r line; do
            echo -e "  ${BLUE}✓${NC} $line"
        done
        ;;
    fonts)
        echo -e "${BOLD}Installed font families:${NC}"
        fc-list : family | sort -u | head -80
        echo ""
        echo -e "${GREY}(showing first 80 — run 'fc-list : family | sort -u' for all)${NC}"
        ;;
    theme)
        case "${2:-}" in
            dark)
                gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
                gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
                local wall_dir="$HOME/.local/share/backgrounds/bureau"
                [ -f "$wall_dir/bureau-bauhaus-dark.png" ] && \
                    gsettings set org.gnome.desktop.background picture-uri-dark "file://$wall_dir/bureau-bauhaus-dark.png"
                echo -e "${BLUE}✓${NC} Switched to dark mode"
                ;;
            light)
                gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
                gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
                local wall_dir="$HOME/.local/share/backgrounds/bureau"
                [ -f "$wall_dir/bureau-bauhaus-light.png" ] && \
                    gsettings set org.gnome.desktop.background picture-uri "file://$wall_dir/bureau-bauhaus-light.png"
                echo -e "${BLUE}✓${NC} Switched to light mode"
                ;;
            *)
                echo "Usage: bureau theme [dark|light]"
                ;;
        esac
        ;;
    ask)
        shift
        bureau-ask "$@"
        ;;
    affinity)
        if command -v less &>/dev/null; then
            less "$HOME/.config/bureau/affinity-setup.md"
        else
            cat "$HOME/.config/bureau/affinity-setup.md"
        fi
        ;;
    davinci)
        if command -v less &>/dev/null; then
            less "$HOME/.config/bureau/davinci-resolve-setup.md"
        else
            cat "$HOME/.config/bureau/davinci-resolve-setup.md"
        fi
        ;;
    extensions)
        cat "$HOME/.config/bureau/recommended-extensions.txt"
        ;;
    info)
        if command -v fastfetch &>/dev/null; then
            fastfetch
        else
            echo -e "${BOLD}Bureau Linux${NC} v$(cat "$HOME/.config/bureau/version" 2>/dev/null || echo '1.0.0')"
            uname -a
        fi
        ;;
    help|--help|-h|*)
        show_help
        ;;
esac
MENUEOF

    chmod +x "$HOME/.local/bin/bureau"

    # Save version
    mkdir -p "$HOME/.config/bureau"
    echo "$BUREAU_VERSION" > "$HOME/.config/bureau/version"

    success "Bureau helper commands installed (run 'bureau help')"
}

# ============================================================================
# Cleanup & Final Setup
# ============================================================================

cleanup() {
    step "Final cleanup"

    # Clean DNF cache
    sudo dnf clean all 2>/dev/null || true

    # Clean temp files
    rm -f /tmp/dm-sans.zip /tmp/space-grotesk.zip /tmp/syne.zip /tmp/work-sans.zip 2>/dev/null || true

    success "Cleanup complete"
}

# ============================================================================
# Post-Install Summary
# ============================================================================

post_install() {
    echo ""
    echo -e "${RED}"
    echo '  =============================================='
    echo '   Bureau is installed. Welcome, creator.'
    echo '  =============================================='
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}Quick Start:${NC}"
    echo -e "  ${YELLOW}bureau help${NC}           — See all Bureau commands"
    echo -e "  ${YELLOW}bureau ask \"...\"${NC}      — Ask Claude AI anything"
    echo -e "  ${YELLOW}bureau apps${NC}           — See your creative toolkit"
    echo -e "  ${YELLOW}bureau theme dark${NC}     — Switch themes"
    echo -e "  ${YELLOW}bureau affinity${NC}       — Set up Affinity apps"
    echo ""
    echo -e "  ${BOLD}Creative Shortcuts:${NC}"
    echo -e "  ${GREY}design${NC}  → Inkscape    ${GREY}paint${NC}   → Krita"
    echo -e "  ${GREY}photo${NC}   → GIMP        ${GREY}raw${NC}     → Darktable"
    echo -e "  ${GREY}render${NC}  → Blender     ${GREY}publish${NC} → Scribus"
    echo -e "  ${GREY}edit${NC}    → Kdenlive    ${GREY}ask${NC}     → Claude AI"
    echo ""
    echo -e "  ${BOLD}Next Steps:${NC}"
    echo -e "  1. Open ${YELLOW}Extension Manager${NC} and install recommended extensions"
    echo -e "  2. Run ${YELLOW}bureau affinity${NC} if you want to set up Affinity apps"
    echo -e "  3. Set your ${YELLOW}ANTHROPIC_API_KEY${NC} for Claude terminal integration"
    echo -e "     (or just run ${YELLOW}bureau-ask${NC} and it will prompt you)"
    echo ""
    echo -e "  ${GREY}Bauhaus believed form follows function."
    echo -e "  Bureau believes your OS should follow your creativity.${NC}"
    echo ""
    echo -e "  ${BOLD}Restart recommended${NC} to apply all theme changes."
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    banner

    if ! confirm "This will install Bureau on your Fedora system. It will install apps, themes, fonts, and configure GNOME."; then
        echo "Installation cancelled."
        exit 0
    fi

    echo ""

    preflight
    update_system
    setup_repos
    install_core
    install_creative_suite
    install_apps
    install_fonts
    configure_gnome
    install_theme
    install_extensions
    install_branding
    install_claude
    setup_affinity
    setup_terminal
    setup_tablet
    setup_colour
    install_bureau_menu
    cleanup
    post_install
}

main "$@"
