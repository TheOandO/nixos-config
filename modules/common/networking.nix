{ config, pkgs, ... }:

{
	# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	# Enable networking
	networking = {
		networkmanager.enable = true;
		# firewall = rec {
		#   allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
		#   allowedUDPPortRanges = allowedTCPPortRanges;
		# };
	};
	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;
}
