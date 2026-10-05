{ config, pkgs, ... }:
{
    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        addKeysToAgent = "yes";
        settings = {
        };
    };
}
