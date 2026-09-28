{ config, pkgs, inputs, ... }:

{
	imports = [ inputs.hermes-agent.homeManagerModules.default ];

	services.hermes-agent = {
		enable = true;
 		gateway.enable = true;
		backend = {
			mode = "dashboard"; # + the browser dashboard on 127.0.0.1:9119
			port = 9119;
		};
	};

	programs.hermes-agent = {
		enable = true;
		desktop.enable = true;
	};
}
