# Bureau

**Beautiful, Opinionated Fedora for Creatives & Designers**

Bureau (French for "desk" / "studio") transforms a standard Fedora installation into a fully-configured creative workstation — Bauhaus-inspired, Claude-powered, made for makers.

Inspired by [Omarchy](https://omarchy.org) and [Omakub](https://omakub.org), but purpose-built for designers, illustrators, photographers, 3D artists, and digital creators rather than developers.

---

## Install

On a fresh Fedora Workstation install, open a terminal and run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/chrischrisjnr/bureau/main/install.sh)
```

That's it. One command. Go make a coffee — it'll take 15-20 minutes.

---

## What You Get

### Desktop
- **Fedora + GNOME on Wayland** — the most stable, polished Linux desktop
- **Bauhaus dark theme** — warm black backgrounds, red/blue/yellow accents
- **Light mode** available (`bureau theme light`)
- **4 fixed workspaces** — one per project or context
- **macOS-style touchpad** — natural scroll, tap to click
- **Curated GNOME extensions** — blur, dock, colour picker, clipboard history

### Creative Suite
| App | Purpose | Replaces |
|-----|---------|----------|
| GIMP | Photo editing & manipulation | Photoshop |
| Inkscape | Vector graphics | Illustrator |
| Krita | Digital painting & illustration | Procreate / Painter |
| Blender | 3D modelling, animation & rendering | Cinema 4D / Maya |
| Darktable | RAW photo processing | Lightroom |
| Scribus | Desktop publishing | InDesign |
| Kdenlive | Video editing | Premiere Pro |
| OBS Studio | Screen recording & streaming | — |
| Figma | UI/UX design (web app) | Sketch / Figma |
| ImageMagick | Command-line image processing | — |

### Everyday Apps
- **Google Chrome** — default browser
- **Spotify** — music (Flatpak)
- **Discord** — community (Flatpak)
- **Obsidian** — notes & knowledge base (Flatpak)
- **LibreOffice** — documents, spreadsheets, presentations
- **Telegram** — messaging (Flatpak)
- **LocalSend** — AirDrop alternative (Flatpak)
- **Bottles** — run Windows apps (for Affinity)

### Claude AI Integration
- **Claude.ai** — pinned as a Chrome web app in your dock
- **Claude Code** — AI coding assistant in your terminal (`claude`)
- **bureau-ask** — quick Claude helper (`bureau-ask "resize all PNGs to 1200px"`)

### Designer Fonts
30+ professional font families pre-installed:
- Inter, DM Sans, Space Grotesk, Work Sans, Syne
- IBM Plex, JetBrains Mono, Fira Sans/Mono
- Source Sans/Serif/Code Pro, Cascadia Code
- Noto Sans/Serif/Mono/Emoji, Liberation, DejaVu

### Drawing Tablet Support
- Wacom tablets work out of the box (Settings > Wacom Tablet)
- For XP-Pen, Huion: install [OpenTabletDriver](https://opentabletdriver.net)

### Colour Management
- colord + GNOME Color Manager for ICC profiles
- ArgyllCMS for display calibration
- Night Light enabled by default (easy on your eyes)

---

## Bureau Commands

```
bureau help           Show all commands
bureau update         Update Bureau & system packages
bureau apps           List installed creative apps
bureau fonts          List installed font families
bureau theme dark     Switch to dark mode
bureau theme light    Switch to light mode
bureau ask "..."      Ask Claude AI a question
bureau affinity       Show Affinity setup guide
bureau extensions     Show recommended GNOME extensions
bureau info           Show system info
```

## Creative Terminal Shortcuts

```
design   → Inkscape       paint    → Krita
photo    → GIMP           raw      → Darktable
render   → Blender        publish  → Scribus
edit     → Kdenlive       ask      → Claude AI
```

## Batch Image Commands

```
batch-resize-1200    Resize all images to 1200px wide
batch-resize-2400    Resize all images to 2400px wide
batch-to-webp        Convert all images to WebP
img-info FILE        Show image details
img-to-png FILE      Convert to PNG
img-to-jpg FILE      Convert to JPG (90% quality)
```

---

## Affinity Apps

Affinity Designer, Photo, and Publisher can run via Bottles (pre-installed). Run `bureau affinity` for the full setup guide. Compatibility is best-effort — check the guide for known issues and alternatives.

---

## Requirements

- **Fedora Workstation** (latest stable release recommended)
- **GNOME desktop** (default on Fedora Workstation)
- **Internet connection** (for downloading packages)
- **~15GB free disk space**
- **Anthropic API key** (optional, for `bureau-ask` terminal AI)

---

## Philosophy

Bureau follows the Bauhaus principle: **form follows function**.

Your operating system should disappear into the background and let you create. Every default has been chosen to reduce friction between you and your work — from the dark theme that's easy on your eyes during long sessions, to the keyboard shortcuts that keep your hands off the mouse, to the AI assistant that's one keystroke away.

Bureau is opinionated. It makes choices so you don't have to. But it's your computer — change anything you want.

---

## Customisation

Bureau uses standard Fedora & GNOME configuration. Everything is in `~/.config/`:

- **Theme**: `~/.config/gtk-4.0/gtk.css` and `~/.config/gtk-3.0/gtk.css`
- **GNOME settings**: `gsettings` (or Settings app)
- **Wallpapers**: `~/.local/share/backgrounds/bureau/`
- **Aliases**: `~/.bashrc`
- **Starship prompt**: `~/.config/starship.toml`
- **Bureau config**: `~/.config/bureau/`

---

## Credits

- Inspired by [Omarchy](https://omarchy.org) and [Omakub](https://omakub.org) by DHH
- Built on [Fedora](https://fedoraproject.org) and [GNOME](https://www.gnome.org)
- Powered by [Claude](https://claude.ai) by Anthropic
- Design philosophy by the [Bauhaus](https://en.wikipedia.org/wiki/Bauhaus) school

---

## Licence

MIT — do whatever you want with it.
