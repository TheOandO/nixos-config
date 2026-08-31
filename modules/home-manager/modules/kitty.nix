{ config, pkgs, ... }:
{
	programs.kitty = {
		enable = true;

		font = {
			name = "DepartureMono Nerd Font Mono";
			size = 12.0;
		};

		settings = {
			# Window
			window_padding_width = 20;
			background_opacity = "0.8";
			background_blur = 32;
			hide_window_decorations = "no";

			# Cursor
			cursor_shape = "block";
			cursor_blink_interval = 1;

			# Scrollback
			scrollback_lines = 3000;

			# Terminal features
			copy_on_select = "yes";
			strip_trailing_spaces = "smart";

			# Tabs
			tab_bar_style = "powerline";
			tab_bar_align = "left";

			# Shell integration
			shell_integration = "enabled";
		};

		keybindings = {
			"ctrl+shift+n" = "new_window";
			"ctrl+t" = "new_tab";
			"ctrl+plus" = "change_font_size all +1.0";
			"ctrl+minus" = "change_font_size all -1.0";
			"ctrl+0" = "change_font_size all 0";
		};

		# Noctalia writes dynamic colors here at runtime — kept as a plain
		# include so home-manager never overwrites Noctalia's live theming.
		extraConfig = ''
			include themes/noctalia.conf
		'';
	};
}
