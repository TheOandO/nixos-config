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

# ─── Step 1b: Work out who the real user is ───────────────────────────────────
# Moved up from the git identity step: the key check below needs the home dir.
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
REAL_GROUP=$(id -gn "$REAL_USER")
REPO_DIR="$USER_HOME/NIXOS"

# Where your backed-up keys must be BEFORE you run this script.
SSH_DIR="$USER_HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
AGE_DIR="$USER_HOME/.config/sops/age"
AGE_KEY="$AGE_DIR/keys.txt"

# ─── Step 1c: Check for backed-up SSH + sops age keys ─────────────────────────
# Runs before anything destructive (step 5a deletes /etc/nixos), so you can stop
# here, copy the files, and run the script again.
echo ""
log "Looking for your backed-up keys..."

HAVE_SSH=false
HAVE_AGE=false

if [ -f "$SSH_KEY" ] && [ -f "$SSH_KEY.pub" ]; then
    HAVE_SSH=true
    success "SSH key found: $SSH_KEY"
else
    warn "SSH key not found (need both $SSH_KEY and $SSH_KEY.pub)."
fi

if [ -f "$AGE_KEY" ]; then
    HAVE_AGE=true
    success "sops age key found: $AGE_KEY"
else
    warn "sops age key not found (expected $AGE_KEY)."
fi

if [ "$HAVE_SSH" = false ] || [ "$HAVE_AGE" = false ]; then
    echo ""
    echo -e "${YELLOW}Reminder — copy your backups into place first:${NC}"
    if [ "$HAVE_SSH" = false ]; then
        echo "  • SSH key  -> $SSH_DIR/   (id_ed25519 and id_ed25519.pub)"
        echo "    Without it, GitHub access and commit signing need a new key afterwards."
    fi
    if [ "$HAVE_AGE" = false ]; then
        echo "  • age key  -> $AGE_DIR/   (keys.txt)"
        echo "    Without it, secrets in your config (e.g. the NAS login) can't be decrypted,"
        echo "    and the rebuild in step 12 will most likely fail."
    fi
    echo ""
    read -rp "Continue anyway without them? [y/N]: " continue_without
    case "$continue_without" in
        y|Y) warn "Continuing without the missing key(s)." ;;
        *)   log "Stopping. Copy the files into place, then run this script again."; exit 0 ;;
    esac
fi

# ─── Step 1d: Fix ownership/permissions on the keys you copied in ─────────────
# Files copied with sudo (or from a USB stick) often have the wrong owner or
# mode, and ssh refuses a private key that others can read.
if [ "$HAVE_SSH" = true ]; then
    chown -R "$REAL_USER":"$REAL_GROUP" "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_KEY"
    chmod 644 "$SSH_KEY.pub"
    success "Fixed ownership and permissions on $SSH_DIR."
fi

if [ "$HAVE_AGE" = true ]; then
    chown "$REAL_USER":"$REAL_GROUP" "$USER_HOME/.config"
    chown -R "$REAL_USER":"$REAL_GROUP" "$USER_HOME/.config/sops"
    chmod 700 "$AGE_DIR"
    chmod 600 "$AGE_KEY"
    success "Fixed ownership and permissions on $AGE_DIR."
fi

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
nixos-rebuild switch --flake "$NIXOS_DIR#$HOST" || {
    if [ "$HAVE_AGE" = false ]; then
        warn "No sops age key was found at $AGE_KEY. A failure here is most likely secret decryption (sops-install-secrets)."
    fi
    error "nixos-rebuild failed. Check the error output above."
}
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
BACKUP_DIR=""

# The age key lives under ~/.config, which this step may move aside. Stash a
# copy in a root-only temp dir so it can be put back after the clone.
AGE_STAGE=""
if [ "$HAVE_AGE" = true ]; then
    AGE_STAGE="$(mktemp -d)"
    cp -a "$AGE_DIR/." "$AGE_STAGE/"
fi

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

# Put the age key back, and keep it out of the dotfiles repo (pull-dot runs
# 'git add .' inside ~/.config, which would otherwise stage the private key).
if [ "$HAVE_AGE" = true ]; then
    mkdir -p "$AGE_DIR"
    cp -a "$AGE_STAGE/." "$AGE_DIR/"
    rm -rf "$AGE_STAGE"
    chown "$REAL_USER":"$REAL_GROUP" "$USER_HOME/.config"
    chown -R "$REAL_USER":"$REAL_GROUP" "$USER_HOME/.config/sops"
    chmod 700 "$AGE_DIR"
    chmod 600 "$AGE_KEY"
    success "sops age key restored to $AGE_DIR."

    if [ -d "$DOTFILES_DIR/.git" ]; then
        mkdir -p "$DOTFILES_DIR/.git/info"
        grep -qxF 'sops/' "$DOTFILES_DIR/.git/info/exclude" 2>/dev/null || echo 'sops/' >> "$DOTFILES_DIR/.git/info/exclude"
        success "sops/ excluded from the dotfiles repo (local .git/info/exclude)."
    fi

    if [ -n "$BACKUP_DIR" ]; then
        warn "Your old ~/.config, including a copy of the age key under sops/age/, is in $BACKUP_DIR. Delete that copy once you've checked everything works."
    fi
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
echo -e "${YELLOW}Next step 1 — SSH keys for GitHub:${NC}"
echo ""

# Your own key: used for your pushes and for signing commits.
if [ "$HAVE_SSH" = true ]; then
    echo "  Your restored key ($SSH_KEY) is in place. It's already on GitHub, so nothing to add."
    echo "  Test it with: sudo -u $REAL_USER ssh -T git@github.com"
else
    echo "  You continued without an SSH key backup. As $REAL_USER, create a new one:"
    echo "    ssh-keygen -t ed25519 -C \"$REAL_USER@$HOST\""
    echo "  Then add the public key at https://github.com/settings/ssh/new, once as an"
    echo "  Authentication key and once as a Signing key, and put it in signing.key"
    echo "  (probably in git.nix). Commits fail to sign until that matches."
fi
echo ""

# Root's key: used by anything that runs as root, such as 'sudo sync-repos.sh'.
# The path is explicit so it can never overwrite the key restored in $SSH_DIR.
ROOT_KEY="/root/.ssh/id_ed25519"
if [ ! -f "$ROOT_KEY" ]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    ssh-keygen -t ed25519 -C "nixos-$HOST" -f "$ROOT_KEY"
fi
echo "  Root's public key (add it at https://github.com/settings/ssh/new if it isn't there yet):"
cat "$ROOT_KEY.pub"
echo ""
echo "  Test it with: sudo ssh -i $ROOT_KEY -T git@github.com"
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
