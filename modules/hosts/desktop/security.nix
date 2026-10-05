{ config, pkgs, ... }:

{
	# security.pam.services.login.fprintAuth = false;
	# security.polkit.enable = true;
	sops = {
		defaultSopsFile = ../../../secrets/desktop.yaml;
		age.keyFile = "/home/matty/.config/sops/age/keys.txt";

		secrets = {
			"omv/username" = { sopsFile = ../../../secrets/desktop.yaml; };
			"omv/password" = { sopsFile = ../../../secrets/desktop.yaml; };
		};
		templates."omv-credentials".content = ''
			username=${config.sops.placeholder."omv/username"}
			password=${config.sops.placeholder."omv/password"}
		'';
	};
}
