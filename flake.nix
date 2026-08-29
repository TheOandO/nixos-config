
{
	description = "Main flake";
	
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		noctalia = {
			url = "github:noctalia-dev/noctalia";
			inputs.nixpkgs.follows = "nixpkgs";
		};
			
		zen-browser = {
			url = "github:youwen5/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		freesmlauncher = {
			url = "github:FreesmTeam/FreesmLauncher";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		compose2nix = {
			url = "github:aksiksi/compose2nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		snappy-switcher = {
			url = "github:OpalAayan/snappy-switcher";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		caelestia-shell = {
		    url = "github:caelestia-dots/shell";
		    inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprmod = {
			url = "github:BlueManCZ/hyprmod";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		creamlinux-installer = {
		      type = "github";
		      owner = "Novattz";
		      repo = "creamlinux-installer";
		      flake = false;
		};

		qylock.url = "github:Darkkal44/qylock";
		dolphin-overlay.url = "github:rumboon/dolphin-overlay";
	};

	outputs = { 
		self,
		nixpkgs,
		noctalia,
		home-manager,
		dolphin-overlay,
		freesmlauncher,
		compose2nix,
		snappy-switcher,
		caelestia-shell,
		hyprmod,
		qylock,
		...
	} @ inputs:
		{
			nixosConfigurations = import ./flake/hosts.nix inputs;
		};
}
