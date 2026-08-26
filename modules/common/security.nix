{ config, pkgs, ... }:

{
    security = {
        pam = {
            services = {
                login.fprintAuth = false;
                hyprland.enableGnomeKeyring = true;
            };
        };
        polkit.enable = true;
    };
}
