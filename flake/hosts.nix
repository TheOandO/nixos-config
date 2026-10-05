{ nixpkgs, home-manager, qylock, ... } @ inputs:
let
	system = "x86_64-linux";
	pkgs = import nixpkgs { inherit system; };
in
{
	laptop = nixpkgs.lib.nixosSystem {
		specialArgs = { inherit inputs; };
		modules = [
			../configuration.nix
			../modules/hosts/laptop/hardware.nix
			../modules/hosts/laptop/programs.nix
			../modules/hosts/laptop/boot.nix
			../modules/hosts/laptop/services.nix
			../modules/hosts/laptop/networking.nix
			../modules/hosts/laptop/security.nix
			../modules/hosts/laptop/system.nix

			#SDDM wallpapers
			qylock.nixosModules.default
			({ pkgs, ... }: {
				programs.qylock = {
					enable = true;
					theme = "sword";          #
				};
			})

			#Home-manager
			home-manager.nixosModules.home-manager
			{
				home-manager = {
					useGlobalPkgs = true;
					useUserPackages = true;
					backupFileExtension = "backup";
					extraSpecialArgs = { inherit inputs; };
					users.matty = {
					    imports = [
							../modules/home-manager/common.nix
							../modules/home-manager/laptop/laptop.nix
						];
					};
				};
			}
		];
	};

	desktop = nixpkgs.lib.nixosSystem {
	    specialArgs = { inherit inputs; };
	    modules = [
			../configuration.nix
	    	../modules/hosts/desktop/hardware.nix
	        ../modules/hosts/desktop/programs.nix
	        ../modules/hosts/desktop/boot.nix
	        ../modules/hosts/desktop/services.nix
	        ../modules/hosts/desktop/networking.nix
	        ../modules/hosts/desktop/security.nix
	        ../modules/hosts/desktop/system.nix

			#Secrets
			inputs.sops-nix.nixosModules.sops

			#SDDM wallpapers
			qylock.nixosModules.default
			({ pkgs, ... }: {
				programs.qylock = {
					enable = true;
					theme = "pixel-dusk-city";
				};
			})

			#Home-manager
		    home-manager.nixosModules.home-manager
		    {
				home-manager = {
					useGlobalPkgs = true;
					useUserPackages = true;
					backupFileExtension = "backup";
					extraSpecialArgs = { inherit inputs; };
					users.matty = {
					    imports = [
							../modules/home-manager/common.nix
							../modules/home-manager/desktop/desktop.nix
						];
					};
				};
		    }
	   ];
	};
}
