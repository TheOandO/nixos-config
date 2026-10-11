{ config, pkgs, ... }:
{
	programs.fish = {
		enable = true;
		interactiveShellInit = ''
 	    	fastfetch
 	    	set fish_greeting ""
		'';

		functions = {
			rebuild = ''
				cd /etc/nixos
				set host (hostname | sed 's/^matty-//')

				echo "🔨 Rebuilding NixOS (with upgrades)..."
				sudo nixos-rebuild switch --flake .#$host

				read -P "🗑️  Collect garbage now? [Y/n] " do_gc
				if test -z "$do_gc"; or test "$do_gc" = "y" -o "$do_gc" = "Y"
					echo "🗑️  Collecting garbage..."
					sudo nix-collect-garbage -d
				end
				echo "✅ Done!"
			'';
			upgrade = ''
				cd /etc/nixos

				set host (hostname | sed 's/^matty-//')

				echo "🔄 Updating flake inputs..."
				nix flake update

				echo "📦 Staging local changes..."
				git add .

				echo "📝 Files to be committed:"
				if git diff --cached --quiet
					echo "   (no changes)"
				else
					git diff --cached --name-status
				end

				read -P "Commit message (leave empty for default): " msg
				if test -z "$msg"
					set msg "update: "(date +%Y-%m-%d)
				end
				set msg "[$host] $msg"

				echo "💾 Committing changes..."
				git commit -m "$msg"; or true

				echo "🔄 Fetching from remote..."
				git fetch origin

				set branch (git branch --show-current)
				set behind (git rev-list --count HEAD..origin/$branch)

				if test $behind -gt 0
					echo "⬇️  Remote has $behind new commit(s), rebasing onto them..."
					set old_head (git rev-parse HEAD)
					if git rebase origin/$branch
						echo "📄 Files changed by the pull:"
						git diff --name-status $old_head HEAD
					else
						echo "❌ Rebase hit conflicts. Fix them, run 'git rebase --continue', then rerun rebuild."
						return 1
					end
				end

				set ahead (git rev-list --count origin/$branch..HEAD)
				if test $ahead -gt 0
					echo "⬆️  Pushing $ahead commit(s)..."
					git push
				else
					echo "✅ Nothing to push."
				end

				read -P "🔨 Run nixos-rebuild switch now? [Y/n] " do_rebuild
				if test -z "$do_rebuild"; or test "$do_rebuild" = "y" -o "$do_rebuild" = "Y"
					echo "🔨 Rebuilding NixOS (with upgrades)..."
					sudo nixos-rebuild switch --upgrade-all --flake .#$host

					echo "✅ Done!"

					read -P "🗑️  Collect garbage now? [Y/n] " do_gc
					if test -z "$do_gc"; or test "$do_gc" = "y" -o "$do_gc" = "Y"
						echo "🗑️  Collecting garbage..."
						sudo nix-collect-garbage -d
					end

					echo "What would you like to do next?"
					echo "  1) Do nothing"
					echo "  2) Reboot"
					echo "  3) Poweroff"
					read -P "Enter choice [1-3, default 1]: " post_action
					switch "$post_action"
						case 2
							echo "🔁 Rebooting..."
							reboot
						case 3
							echo "⏻  Powering off..."
							poweroff
						case '*'
							echo "✅ Done!"
					end
				else
					echo "⏭️  Skipping rebuild."
				end
			'';
			pull-nix = ''
				cd /etc/nixos

				set host (hostname | sed 's/^matty-//')

				echo "🔄 Fetching from remote..."
				git fetch origin

				set branch (git branch --show-current)
				echo "🌿 Current branch: $branch"

				echo "📝 Latest commit on origin/$branch:"
				git log origin/$branch -1 --oneline

				set remote_files (git diff --name-only HEAD...origin/$branch)
				for f in (git diff --name-only HEAD)
					if contains -- $f $remote_files
						echo "⚠️  $f was edited locally and on the remote"
					end
				end

				set old_head (git rev-parse HEAD)

				echo "🔄 Pulling (your local edits are kept aside and restored)..."
				if git pull --rebase --autostash origin $branch
					if git diff --quiet $old_head HEAD
						echo "📄 No file changes from the pull."
					else
						echo "📄 Files changed by the pull:"
						git diff --name-status $old_head HEAD
					end
				else
					echo "❌ Pull stopped (conflict). Your edits are still in 'git stash list'."
					return 1
				end

				read -P "🔨 Run nixos-rebuild switch now? [Y/n] " do_rebuild
				if test -z "$do_rebuild"; or test "$do_rebuild" = "y" -o "$do_rebuild" = "Y"
					echo "🔨 Rebuilding NixOS..."
					sudo nixos-rebuild switch --flake /etc/nixos#$host

					echo "✅ Done!"

					read -P "🗑️  Collect garbage now? [Y/n] " do_gc
					if test -z "$do_gc"; or test "$do_gc" = "y" -o "$do_gc" = "Y"
						echo "🗑️  Collecting garbage..."
						sudo nix-collect-garbage -d
					end

					echo "What would you like to do next?"
					echo "  1) Do nothing"
					echo "  2) Reboot"
					echo "  3) Poweroff"
					read -P "Enter choice [1-3, default 1]: " post_action
					switch "$post_action"
						case 2
							echo "🔁 Rebooting..."
							reboot
						case 3
							echo "⏻  Powering off..."
							poweroff
						case '*'
							echo "👍 Skipping reboot/poweroff."
					end
				else
					echo "⏭️  Skipping rebuild."
				end
			'';
			pull-dot = ''
				cd ~/.config

				echo "🔄 Fetching from remote..."
				git fetch origin

				set branch (git branch --show-current)
				echo "🌿 Current branch: $branch"

				echo "📝 Latest commit on origin/$branch:"
				git log origin/$branch -1 --oneline

				set remote_files (git diff --name-only HEAD...origin/$branch)
				for f in (git diff --name-only HEAD)
					if contains -- $f $remote_files
						echo "⚠️  $f was edited locally and on the remote"
					end
				end

				set old_head (git rev-parse HEAD)

				echo "🔄 Pulling (your local edits are kept aside and restored)..."
				if git pull --rebase --autostash origin $branch
					if git diff --quiet $old_head HEAD
						echo "📄 No file changes from the pull."
					else
						echo "📄 Files changed by the pull:"
						git diff --name-status $old_head HEAD
					end
				else
					echo "❌ Pull stopped (conflict). Your edits are still in 'git stash list'."
					return 1
				end

				echo "✅ Done!"
			'';

			cleanup = ''
				echo "🗑️ Collecting garbage..."
				sudo nix-collect-garbage -d
				echo "✅ Done!"
			'';
		};
	};


}
