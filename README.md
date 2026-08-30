# NixOS Config

My personal NixOS configuration using flakes and home-manager, supporting multiple hosts.

## Structure

> **Note:** `/etc/nixos` is a symlink to `~/NIXOS`. On a fresh install, `setup.sh` clones this repo directly into `~/NIXOS` (user-owned) and symlinks `/etc/nixos` to it — so day-to-day editing and git operations never require `sudo`. Only `nixos-rebuild switch` (and `reboot`/`poweroff`) still need it.

```
/etc/nixos/  ->  ~/NIXOS/
├── flake.nix              # Flake inputs and outputs (delegates host definitions to flake/hosts.nix)
├── flake.lock             # Pinned input versions
├── configuration.nix      # Shared base config, imports common modules
├── setup.sh               # Automated setup script for new machines
├── flake/
│   └── hosts.nix          # nixosConfigurations definitions for all hosts (laptop, desktop)
└── modules/
    ├── common/
    │   ├── programs.nix       # Shared system packages and programs
    │   ├── services.nix       # Shared system services
    │   ├── networking.nix     # Network configuration
    │   ├── security.nix       # Security settings
    │   ├── system.nix         # Miscellaneous system settings
    │   └── boot.nix           # Bootloader config
    ├── home-manager/
    │   ├── common.nix         # Shared home manager config
    │   ├── fish-functions.nix # Shared, hostname-aware fish functions (rebuild, pull-nix, pull-dot)
    │   ├── laptop.nix         # Laptop-specific home config
    │   └── desktop.nix        # Desktop-specific home config
    └── hosts/
        ├── laptop/
        │   ├── hardware.nix       # Laptop hardware config (auto-generated)
        │   ├── programs.nix       # Laptop-specific packages (Niri, Noctalia)
        │   ├── services.nix       # Laptop-specific services
        │   ├── networking.nix     # Laptop-specific networking config
        │   ├── security.nix       # Laptop-specific security config
        │   ├── system.nix         # Laptop-specific system config
        │   └── boot.nix           # Laptop bootloader config
        └── desktop/
            ├── hardware.nix       # Desktop hardware config (auto-generated)
            ├── programs.nix       # Desktop-specific packages
            ├── services.nix       # Desktop-specific services
            ├── networking.nix     # Desktop-specific networking config
            ├── security.nix       # Desktop-specific security config
            ├── system.nix         # Desktop-specific system config
            └── boot.nix           # Desktop bootloader config
```

## Hosts

| Host | Desktop | File Manager | Notes |
|------|---------|--------------|-------|
| `laptop` | Niri (Wayland) + Noctalia | Nautilus | Primary laptop |
| `desktop` | Hyprland + Noctalia/KDE Plasma | Dolphin | Main workstation |

## Installing on a New Machine

### 1. Boot NixOS installer and install base system

Follow the [NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation). During install, let NixOS generate a default `configuration.nix`, which you will need the `hardware-configuration.nix` it produces.

### 2. Run the setup script

The setup script handles everything automatically: cloning the repo, copying hardware config, and rebuilding the system.

```bash
curl -o /tmp/setup.sh https://raw.githubusercontent.com/TheOandO/nixos-config/main/setup.sh
chmod +x /tmp/setup.sh
sudo bash /tmp/setup.sh
```

The script will:
1. Ask which host to set up (`laptop` or `desktop`)
2. Ask for your git username and email
3. Back up the installer-generated `hardware-configuration.nix`
4. Remove the installer's `/etc/nixos` and clone this repo into `~/NIXOS` instead (owned by your user)
5. Symlink `/etc/nixos` to `~/NIXOS`
6. Copy `hardware-configuration.nix` to the correct host folder
7. Commit the hardware config locally
8. Set the remote to SSH
9. Update flake inputs
10. Run `nixos-rebuild switch`
11. Fix ownership of `~/NIXOS` (root touched some files during setup — this is the last time `sudo` is needed for the repo)
12. Clone the dotfiles repo (`nixos-dot-files`) into `~/.config`, checked out to the branch matching the host you picked

### 3. Set up SSH key for GitHub (for future pushes)

The setup script will print these instructions at the end, but for reference:

```bash
sudo ssh-keygen -t ed25519 -C "nixos-<hostname>"
sudo cat /root/.ssh/id_ed25519.pub
# Add this key to: https://github.com/settings/ssh/new
sudo ssh -T git@github.com  # verify it works
```

## Updating

After making changes to any config file, run:

```bash
rebuild
```

This prompts for a commit message (defaults to today's date if left empty, tagged with the current host), commits, pushes to GitHub, and updates flake inputs — all as your normal user, no `sudo` needed since `/etc/nixos` is a symlink to your user-owned `~/NIXOS`. It then asks whether to run `nixos-rebuild switch` (the one step that does need `sudo`), and if you rebuild, whether to reboot, power off, or do nothing afterward.

To pull down changes made on another machine instead of pushing local ones:

```bash
pull-nix   # syncs /etc/nixos, shows the latest remote commit, rebases local changes on top, then optionally rebuilds and reboots/powers off
pull-dot   # same sync flow for ~/.config dotfiles, no rebuild step
```
