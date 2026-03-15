#!/usr/bin/env bash

# ============================================================================
# COLOR CODES & LOGGING
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

set -e
trap 'log_error "Installation failed at line $LINENO"; exit 1' ERR

# ============================================================================
# SYSTEM CHECKS
# ============================================================================

log_info "Checking system requirements..."

if ! command -v pacman &>/dev/null; then
    log_error "pacman not found. This requires Arch Linux."
    exit 1
fi
log_success "Arch Linux detected"

if [[ $EUID -eq 0 ]]; then
    log_error "Do not run as root. sudo will be used when needed."
    exit 1
fi
log_success "Running as regular user"

if ! command -v sudo &>/dev/null; then
    log_error "sudo is not installed"
    exit 1
fi
log_success "sudo is available"

# ============================================================================
# VERIFY REPOSITORY
# ============================================================================

log_info "Verifying repository structure..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$SCRIPT_DIR/Waybar" ]]; then
    log_error "Waybar directory not found"
    exit 1
fi
log_success "Waybar directory found"

# ============================================================================
# CORE DEPENDENCIES ONLY (Required for Waybar to function)
# ============================================================================

log_info "Installing Waybar core dependencies..."

PACKAGES=(
    waybar                # The status bar itself
    ttf-font-awesome      # Icons for waybar modules
    noto-fonts            # Font support
    jq                    # Required by weather.sh script
    playerctl             # For media player controls
    grim                  # Screenshot tool
    slurp                 # Region selection tool
    wl-clipboard          # Clipboard management for Wayland
)

# Check which packages need installation
PACKAGES_TO_INSTALL=()
for package in "${PACKAGES[@]}"; do
    if pacman -Q "$package" &>/dev/null; then
        log_success "$package already installed"
    else
        PACKAGES_TO_INSTALL+=("$package")
    fi
done

if [[ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]]; then
    log_info "Installing ${#PACKAGES_TO_INSTALL[@]} package(s)..."
    sudo pacman -S --needed --noconfirm "${PACKAGES_TO_INSTALL[@]}"
    log_success "Dependencies installed"
else
    log_success "All core dependencies already installed"
fi

# ============================================================================
# OPTIONAL DEPENDENCIES (User can install separately if needed)
# ============================================================================

log_info ""
log_info "Optional packages (install manually if desired):"
echo "  • btop              - System monitor (for system-monitor.sh)"
echo "  • figlet            - ASCII art text (for installupdates.sh)"
echo "  • yay or paru       - AUR helper (for AUR package updates)"
echo "  • flatpak           - Flatpak package manager"
echo "  • pavucontrol       - Audio control (on-click for pulseaudio module)"
echo ""

# ============================================================================
# INSTALL WAYBAR CONFIG
# ============================================================================

log_info "Installing Waybar configuration..."

CONFIG_DIR="$HOME/.config/waybar"

# Backup existing config
if [[ -d "$CONFIG_DIR" ]]; then
    log_warning "Existing Waybar config found at $CONFIG_DIR"
    read -p "Create backup? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$CONFIG_DIR" "$BACKUP_DIR"
        log_success "Backup created: $BACKUP_DIR"
    fi
fi

mkdir -p "$CONFIG_DIR"
cp -r "$SCRIPT_DIR/Waybar"/* "$CONFIG_DIR/"
log_success "Configuration files installed"

# ============================================================================
# MAKE SCRIPTS EXECUTABLE
# ============================================================================

log_info "Making scripts executable..."

if [[ -d "$CONFIG_DIR/scripts" ]]; then
    chmod +x "$CONFIG_DIR"/scripts/*.sh 2>/dev/null || true
    SCRIPT_COUNT=$(find "$CONFIG_DIR/scripts" -name "*.sh" -type f | wc -l)
    log_success "Made $SCRIPT_COUNT script(s) executable"
fi

# ============================================================================
# COMPLETION
# ============================================================================

echo ""
log_success "Installation complete!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review config: $CONFIG_DIR"
echo "  2. (Optional) Install optional packages:"
echo "     sudo pacman -S btop yay pavucontrol"
echo "  3. Restart Waybar:"
echo "     ${YELLOW}killall waybar; waybar &${NC}"
echo ""

read -p "Restart Waybar now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    killall waybar 2>/dev/null || true
    waybar &
    log_success "Waybar restarted"
fi

exit 0