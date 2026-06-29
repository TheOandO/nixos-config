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
	};

	outputs = { self, nixpkgs, noctalia, home-manager, ... } @ inputs:
	{
		nixosConfigurations = {
	    	laptop = nixpkgs.lib.nixosSystem {
		    	system = "x86_64-linux";
		      	specialArgs = { inherit inputs; };
		      	modules = [
			        ./configuration.nix
			        ./modules/hosts/laptop/hardware.nix
			        ./modules/hosts/laptop/programs.nix
			        ./modules/hosts/laptop/boot.nix
			        ./modules/hosts/laptop/services.nix
			        ./modules/hosts/laptop/networking.nix
			        ./modules/hosts/laptop/security.nix
			        ./modules/hosts/laptop/system.nix
			        home-manager.nixosModules.home-manager
			        {
				          home-manager.useGlobalPkgs = true;
				          home-manager.useUserPackages = true;
				          home-manager.backupFileExtension = "backup";
				          home-manager.users.matty = {
					            imports = [
						              ./modules/home-manager/common.nix
						              ./modules/home-manager/laptop.nix
					            ];
				          };
			        }
		      	];
		    };
	
		    desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
			    specialArgs = { inherit inputs; };
			    modules = [
					./configuration.nix
			    	./modules/hosts/desktop/hardware.nix
			        ./modules/hosts/desktop/programs.nix
			        ./modules/hosts/desktop/boot.nix
			        ./modules/hosts/desktop/services.nix
			        ./modules/hosts/desktop/networking.nix
			        ./modules/hosts/desktop/security.nix
			        ./modules/hosts/desktop/system.nix
				    home-manager.nixosModules.home-manager
				        {
					          home-manager.useGlobalPkgs = true;
					          home-manager.useUserPackages = true;
					          home-manager.backupFileExtension = "backup";
					          home-manager.users.matty = {
						            imports = [
							              ./modules/home-manager/common.nix
							              ./modules/home-manager/desktop.nix
						            ];
					          };
				        }
			      ];
		    };
	  	};
	};
}
