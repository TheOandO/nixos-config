#!/usr/bin/env bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_URL="https://github.com/TheOandO/nixos-config.git"
NIXOS_DIR="/etc/nixos"
HARDWARE_CONFIG="/tmp/hardware-configuration.nix"

log()     { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─── Step 1: Check root ───────────────────────────────────────────────────────
log "Checking root privileges..."
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root. Try: sudo bash setup.sh"
fi
success "Running as root."

# ─── Step 2: Ask host ─────────────────────────────────────────────────────────
echo ""
echo "Which host are you setting up?"
echo "  1) laptop"
echo "  2) desktop"
read -rp "Enter choice [1/2]: " host_choice

case "$host_choice" in
    1) HOST="laptop" ;;
    2) HOST="desktop" ;;
    *) error "Invalid choice. Please enter 1 or 2." ;;
esac
success "Host set to: $HOST"

# ─── Step 3: Git identity ─────────────────────────────────────────────────────
echo ""
log "Setting up git identity for root..."
read -rp "Git username: " git_username
read -rp "Git email: " git_email

if [ -z "$git_username" ] || [ -z "$git_email" ]; then
    error "Git username and email cannot be empty."
fi

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch "main"
success "Git identity set: $git_username <$git_email>"

# ─── Step 4: Backup hardware config ───────────────────────────────────────────
echo ""
log "Backing up hardware-configuration.nix..."
if [ ! -f "$NIXOS_DIR/hardware-configuration.nix" ]; then
    error "hardware-configuration.nix not found in $NIXOS_DIR. Make sure NixOS was installed first."
fi
cp "$NIXOS_DIR/hardware-configuration.nix" "$HARDWARE_CONFIG"
success "Hardware config backed up to $HARDWARE_CONFIG"

# ─── Step 5: Clear /etc/nixos ─────────────────────────────────────────────────
echo ""
log "Clearing $NIXOS_DIR..."
rm -rf "${NIXOS_DIR:?}"/*
success "$NIXOS_DIR cleared."

# ─── Step 6: Clone repo ───────────────────────────────────────────────────────
echo ""
log "Cloning repo into $NIXOS_DIR..."
git clone "$REPO_URL" "$NIXOS_DIR" || error "Failed to clone repo. Check your internet connection and repo URL."
success "Repo cloned successfully."

# ─── Step 7: Make scripts executable ─────────────────────────────────────────
echo ""
log "Making scripts executable..."
chmod +x "$NIXOS_DIR/setup.sh" || warn "setup.sh not found, skipping."
chmod +x "$NIXOS_DIR/sync-repos.sh" || warn "sync-repos.sh not found, skipping."
success "Scripts are now executable."

# ─── Step 8: Copy hardware config ─────────────────────────────────────────────
echo ""
log "Copying hardware config for host: $HOST..."
TARGET_DIR="$NIXOS_DIR/modules/hosts/$HOST"

if [ ! -d "$TARGET_DIR" ]; then
    error "Host directory $TARGET_DIR not found in repo. Make sure the host folder exists."
fi

cp "$HARDWARE_CONFIG" "$TARGET_DIR/hardware.nix"
success "Hardware config copied to $TARGET_DIR/hardware.nix"

# ─── Step 9: Git add and commit hardware config ────────────────────────────────
echo ""
log "Committing hardware config..."
cd "$NIXOS_DIR"
git add "modules/hosts/$HOST/hardware.nix" || error "Failed to git add hardware config."
git commit -m "add: $HOST hardware config" || error "Failed to commit hardware config."
success "Hardware config committed."

# ─── Step 10: Set remote to SSH ───────────────────────────────────────────────
echo ""
log "Setting remote origin to SSH..."
git -C "$NIXOS_DIR" remote set-url origin git@github.com:TheOandO/nixos-config.git || error "Failed to set remote URL."
success "Remote origin set to SSH."

# ─── Step 11: Nix flake update ────────────────────────────────────────────────
echo ""
log "Updating flake inputs..."
nix flake update || error "Failed to update flake inputs. Check your internet connection."
success "Flake inputs updated."

# ─── Step 12: Rebuild ─────────────────────────────────────────────────────────
echo ""
log "Running nixos-rebuild for $HOST..."
nixos-rebuild switch --flake "$NIXOS_DIR#$HOST" || error "nixos-rebuild failed. Check the error output above."
success "NixOS rebuilt successfully for $HOST."

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete for: $HOST          ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next step 1 — Set up SSH key for GitHub pushes:${NC}"
echo ""
ssh-keygen -t ed25519 -C "nixos-$HOST"
cat /root/.ssh/id_ed25519.pub
echo ""
echo "  Then add the key to: https://github.com/settings/ssh/new"
echo "  And test with: ssh -T git@github.com"
echo ""

echo -e "${YELLOW}Next step 2 — Add sync-repos.sh to your compositor startup:${NC}"
echo ""

if [ "$HOST" = "laptop" ]; then
    echo "  You are on the laptop (Niri). Add this to your niri config:"
    echo ""
    echo '  spawn-at-startup "kitty" "--" "bash" "-c" "sudo /etc/nixos/sync-repos.sh; exec fish"'
    echo ""
    echo "  Or in home.nix:"
    echo '  programs.niri.settings.spawn-at-startup = ['
    echo '    { command = [ "kitty" "--" "bash" "-c" "sudo /etc/nixos/sync-repos.sh; exec fish" ]; }'
    echo '  ];'
else
    echo "  You are on the desktop (Hyprland). Add this to your hyprland config:"
    echo ""
    echo "  exec-once = kitty -- bash -c 'sudo /etc/nixos/sync-repos.sh; exec fish'"
    echo ""
    echo "  Or in your Lua config:"
    echo '  hl.on("hyprland.start", function()'
    echo "      hl.exec_cmd(\"kitty -- bash -c 'sudo /etc/nixos/sync-repos.sh; exec fish'\")"
    echo '  end)'
fi
echo ""
