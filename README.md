# NixOS Config

My personal NixOS configuration using flakes and home-manager, supporting multiple hosts.

## Structure

```
/etc/nixos/
├── flake.nix              # Flake inputs and system definitions (all hosts)
├── flake.lock             # Pinned input versions
├── configuration.nix      # Shared base config, imports common modules
├── setup.sh               # Automated setup script for new machines
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
    │   ├── laptop.nix         # Laptop-specific home config
    │   └── desktop.nix        # Desktop-specific home config
    └── hosts/
        ├── laptop/
        │   ├── hardware.nix       # Laptop hardware config (auto-generated)
        │   ├── programs.nix       # Laptop-specific packages (Niri, Noctalia, Nautilus)
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
| `laptop` | Niri (Wayland) + Noctalia | Nautilus | Primary mobile machine |
| `desktop` | Hyprland + Noctalia | Dolphin | Main workstation |

## Installing on a New Machine

### 1. Boot NixOS installer and install base system

Follow the [NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation). During install, let NixOS generate a default `configuration.nix` — you will need the `hardware-configuration.nix` it produces.

### 2. Run the setup script

The setup script handles everything automatically — cloning the repo, copying hardware config, and rebuilding the system.

```bash
curl -o /tmp/setup.sh https://raw.githubusercontent.com/TheOandO/nixos-config/main/setup.sh
chmod +x /tmp/setup.sh
sudo bash /tmp/setup.sh
```

The script will:
1. Ask which host to set up (`laptop` or `desktop`)
2. Ask for your git username and email
3. Clear `/etc/nixos` and clone this repo
4. Copy `hardware-configuration.nix` to the correct host folder
5. Commit the hardware config locally
6. Set the remote to SSH
7. Update flake inputs
8. Run `nixos-rebuild switch`

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

This prompts for a commit message (defaults to today's date if left empty), commits, pushes to GitHub, updates flake inputs, and rebuilds the system in one command.
