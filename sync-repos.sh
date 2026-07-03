#!/usr/bin/env bash

set -euo pipefail

NIXOS_DIR="/etc/nixos"
DOTFILES_DIR="/home/matty/.config"

log()     { echo "[INFO] $1"; }
success() { echo "[OK] $1"; }
error()   { echo "[ERROR] $1"; }

sync_repo() {
    local dir="$1"
    local name="$2"

    log "Syncing $name..."

    if [ ! -d "$dir/.git" ]; then
        error "$name: not a git repo at $dir, skipping."
        return
    fi

    cd "$dir"
    git stash
    git pull --rebase || error "$name: pull failed, restoring stash."
    git stash pop || true

    success "$name synced."
}

sync_repo "$NIXOS_DIR" "NixOS config"
sync_repo "$DOTFILES_DIR" "Dotfiles"
