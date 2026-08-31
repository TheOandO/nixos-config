{ nixpkgs, home-manager, qylock, ... } @ inputs:
{
	laptop = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
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

			qylock.nixosModules.default
			({ pkgs, ... }: {
				programs.qylock = {
					enable = true;
					theme = "sword";          #
				};
			})

			{
			    nixpkgs.overlays = [
			    	(final: prev: {
			    		snappy-switcher = prev.snappy-switcher.overrideAttrs (old: {
			    	    	postInstall = builtins.replaceStrings
			    	        	[ ''substituteInPlace snappy-switcher.service \
			    	            	--replace-fail "/usr/local" "$out"'' ]
			    	       		[ ''substituteInPlace snappy-switcher.service \
			    	            	--replace-fail "/usr/bin/snappy-switcher" "$out/bin/snappy-switcher"'' ]
			    	        	old.postInstall;
			    	    });
			    	  })
			    ];							
			}


			home-manager.nixosModules.home-manager
			{
				  home-manager.useGlobalPkgs = true;
				  home-manager.useUserPackages = true;
				  home-manager.backupFileExtension = "backup";
				  home-manager.users.matty = {
					    imports = [
							../modules/home-manager/common.nix
							../modules/home-manager/laptop.nix
					    ];
				  };
			}
		];
	};

	desktop = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
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

			qylock.nixosModules.default
			({ pkgs, ... }: {
				programs.qylock = {
					enable = true;
					theme = "pixel-dusk-city";
				};
			})


		    home-manager.nixosModules.home-manager
		    {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.backupFileExtension = "backup";
				home-manager.users.matty = {
					imports = [
						../modules/home-manager/common.nix
						../modules/home-manager/desktop.nix
				    ];
			    };
		    }
	   ];
	};
}
