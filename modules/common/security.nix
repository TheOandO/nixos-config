{ config, pkgs, ... }:

{
	security.pam.services.login.fprintAuth = false;
    security.polkit.enable = true;
    security.pam.services.hyprland.enableGnomeKeyring = true;
}
