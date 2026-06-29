# NixOS Config

My personal NixOS configuration using flakes and home-manager, supporting multiple hosts.

## Structure

```
/etc/nixos/
├── flake.nix              # Flake inputs and system definitions (all hosts)
├── flake.lock             # Pinned input versions
├── configuration.nix      # Shared base config, imports common modules
└── modules/
    ├── common/
    │   ├── programs.nix       # Shared system packages and programs
    │   ├── services.nix       # Shared system services
    │   ├── networking.nix     # Network configuration
    │   ├── security.nix       # Security settings
    │   └── system.nix         # Miscellaneous system settings
    │   └── boot.nix           # Bootloader config
    ├── home-manager/
    │   ├── common.nix       # Shared home manager config
    │   ├── laptop.nix       # Laptop-specific home config
    │   ├── desktop.nix      # Desktop-specific home config
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
            ├── hardware.nix       # Desktop hardware config (placeholder)
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
| `desktop` | KDE Plasma 6 | Dolphin | Main workstation |

## Installing on a New Machine

### 1. Boot NixOS installer and install base system

Follow the [NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation). During install, let NixOS generate a default `configuration.nix` — you'll need the `hardware-configuration.nix` it produces.

### 2. Clone this repo

```bash
sudo git clone https://github.com/TheOandO/nixos-config.git /etc/nixos
```

### 3. Add hardware config

Copy the hardware config generated during install into the correct host folder:

```bash
# For laptop:
sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/modules/hosts/laptop/hardware.nix

# For desktop:
sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/modules/hosts/desktop/hardware.nix
```

### 4. Track the new file with git

```bash
cd /etc/nixos
sudo git add .
```

### 5. Rebuild

```bash
# Laptop:
sudo nixos-rebuild switch --flake /etc/nixos#laptop

# Desktop:
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

### 6. Set user password

```bash
sudo passwd matty
```

### 7. Set up SSH key for GitHub (optional, for pushing config changes)

```bash
sudo ssh-keygen -t ed25519 -C "nixos-root"
sudo cat /root/.ssh/id_ed25519.pub
# Add this key to GitHub → Settings → SSH keys
sudo ssh -T git@github.com  # verify it works
```

## Updating

After making changes to any config file, run:

```bash
rebuild
```

This prompts for a commit message (defaults to today's date if left empty), commits, pushes to GitHub, updates flake inputs, and rebuilds the system in one command.

## Key Software

### Shared
- **Terminal**: Kitty
- **Shell**: Fish with Tide prompt
- **Browser**: Zen Browser
- **Editor**: Micro

### Laptop
- **Window compositor**: Niri (Wayland)
- **Desktop shell**: Noctalia
- **File manager**: Nautilus

### Desktop
- **Desktop environment**: KDE Plasma 6
- **File manager**: Dolphin
