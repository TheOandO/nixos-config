#!/usr/bin/env bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_URL="https://github.com/TheOandO/nixos-config.git"
DOTFILES_REPO_URL="https://github.com/TheOandO/nixos-dot-files.git"
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

# ─── Step 3: Git identity ──────────────────────────────────────────────────────
# Two uses: (1) baked directly into git.nix so home-manager's declarative
# programs.git.settings has your real identity from the first rebuild onward,
# and (2) a repo-local .git/config identity for this script's own commit in
# step 9, which happens before that rebuild has applied anything.
echo ""
log "Git identity..."
read -rp "Git username: " git_username
read -rp "Git email: " git_email

if [ -z "$git_username" ] || [ -z "$git_email" ]; then
    error "Git username and email cannot be empty."
fi

REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
REPO_DIR="$USER_HOME/NIXOS"

# ─── Step 4: Backup hardware config ───────────────────────────────────────────
echo ""
log "Backing up hardware-configuration.nix..."
if [ ! -f "$NIXOS_DIR/hardware-configuration.nix" ]; then
    error "hardware-configuration.nix not found in $NIXOS_DIR. Make sure NixOS was installed first."
fi
cp "$NIXOS_DIR/hardware-configuration.nix" "$HARDWARE_CONFIG"
success "Hardware config backed up to $HARDWARE_CONFIG"

# ─── Step 5a: Remove installer's /etc/nixos, clone repo into ~/NIXOS ──────────
echo ""
log "Removing installer-generated $NIXOS_DIR..."
rm -rf "${NIXOS_DIR:?}"
success "$NIXOS_DIR removed."

echo ""
log "Cloning repo into $REPO_DIR..."
git clone "$REPO_URL" "$REPO_DIR" || error "Failed to clone repo. Check your internet connection and repo URL."
chown -R "$REAL_USER":"$REAL_USER" "$REPO_DIR"
success "Repo cloned to $REPO_DIR (owned by $REAL_USER)."

# ─── Step 5b: Bake git identity into the home-manager git.nix module ─────────
echo ""
log "Setting user.name/user.email in git.nix..."
GIT_NIX="$REPO_DIR/modules/home-manager/modules/git.nix"

if [ ! -f "$GIT_NIX" ]; then
    error "git.nix not found at $GIT_NIX. Check the path matches your repo layout."
fi

# Escape / and & so they can't break the sed replacement.
esc_name=$(printf '%s' "$git_username" | sed -e 's/[\/&]/\\&/g')
esc_email=$(printf '%s' "$git_email" | sed -e 's/[\/&]/\\&/g')

sed -i "s/user\.name = \"[^\"]*\";/user.name = \"$esc_name\";/" "$GIT_NIX"
sed -i "s/user\.email = \"[^\"]*\";/user.email = \"$esc_email\";/" "$GIT_NIX"
success "git.nix updated with $git_username <$git_email>."

# Repo-local identity so root's one-time hardware-config commit below works
# without needing root's own gitconfig — local config lives in .git/config,
# independent of whichever user's $HOME is running the command. Matches the
# values just baked into git.nix so the commit author is consistent with
# what home-manager will apply after the rebuild.
git -C "$REPO_DIR" config user.name "$git_username"
git -C "$REPO_DIR" config user.email "$git_email"

# ─── Step 6: Symlink /etc/nixos to ~/NIXOS ────────────────────────────────────
echo ""
log "Symlinking $NIXOS_DIR -> $REPO_DIR..."
ln -s "$REPO_DIR" "$NIXOS_DIR"
success "$NIXOS_DIR now points to $REPO_DIR."

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

# ─── Step 9: Git add and commit hardware config + git identity ────────────────
echo ""
log "Committing hardware config and git identity..."
cd "$NIXOS_DIR"
git add "modules/hosts/$HOST/hardware.nix" "modules/home-manager/modules/git.nix" || error "Failed to git add changes."
git commit -m "add: $HOST hardware config, set git identity" || error "Failed to commit changes."
success "Hardware config and git identity committed."

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

# ─── Step 12b: Fix ownership after root-run git/nix operations ───────────────
echo ""
log "Restoring ownership of $REPO_DIR to $REAL_USER (root touched files during setup)..."
chown -R "$REAL_USER":"$REAL_USER" "$REPO_DIR"
success "$REPO_DIR is owned by $REAL_USER — no sudo needed for future git/nix commands."

# ─── Step 13: Set up dotfiles repo ────────────────────────────────────────────
echo ""
log "Setting up dotfiles for $HOST..."

DOTFILES_DIR="$USER_HOME/.config"

if [ -d "$DOTFILES_DIR/.git" ]; then
    warn "$DOTFILES_DIR is already a git repo, skipping dotfiles clone. Run 'pull-dot' manually to sync."
else
    if [ -d "$DOTFILES_DIR" ] && [ "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]; then
        BACKUP_DIR="$USER_HOME/.config-backup-$(date +%Y%m%d%H%M%S)"
        warn "$DOTFILES_DIR already has content, backing it up to $BACKUP_DIR first."
        mv "$DOTFILES_DIR" "$BACKUP_DIR"
    fi

    log "Cloning dotfiles repo into $DOTFILES_DIR (branch: $HOST)..."
    git clone --branch "$HOST" "$DOTFILES_REPO_URL" "$DOTFILES_DIR" || error "Failed to clone dotfiles repo. Check the branch '$HOST' exists on $DOTFILES_REPO_URL."
    chown -R "$REAL_USER":"$REAL_USER" "$DOTFILES_DIR"
    success "Dotfiles cloned to $DOTFILES_DIR on branch '$HOST'."
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete for: $HOST          ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "Config repo: $REPO_DIR (symlinked from /etc/nixos, owned by $REAL_USER)."
echo -e "Dotfiles cloned to $DOTFILES_DIR on branch '$HOST' (run 'pull-dot' any time to resync)."
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
