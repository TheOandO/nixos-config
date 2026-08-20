{ config, pkgs, ... }:

{
	fileSystems."/mnt/nas" = {
		device = "//mattyomv.local/NAS/";
	    fsType = "cifs";
	    options = let
	    	automount_opts = "x-systemd.automount,noauto";
	    in [
	        "credentials=/etc/nixos/credentials/omv"
	        "_netdev"
	        "uid=1000"
	        "gid=100"
	        "file_mode=0664"
	        "dir_mode=0775"
	        automount_opts
	     ];
	};
}
