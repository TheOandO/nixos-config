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

				echo "🔄 Updating flake inputs..."
				sudo nix flake update

				echo "📦 Staging local changes..."
				git add .

				read -P "Commit message (leave empty for default): " msg
				if test -z "$msg"
					set msg "update: "(date +%Y-%m-%d)
				end
				set msg "[$host] $msg"

				echo "💾 Committing changes..."
				git commit -m "$msg"; or true

				echo "🔄 Fetching from remote..."
				git fetch origin

				echo "⚡ Rebasing with local changes taking priority..."
				git rebase -X ours origin/(git branch --show-current); or true

				echo "⬆️  Force pushing to remote..."
				git push --force

				read -P "🔨 Run nixos-rebuild switch now? [Y/n] " do_rebuild
				if test -z "$do_rebuild"; or test "$do_rebuild" = "y" -o "$do_rebuild" = "Y"
					echo "🔨 Rebuilding NixOS (with upgrades)..."
					sudo nixos-rebuild switch --upgrade-all --flake .#$host

					echo "✅ Done!"

					read -P "Reboot, poweroff, or do nothing? [r/p/N] " post_action
					switch "$post_action"
						case r R
							echo "🔁 Rebooting..."
							reboot
						case p P
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

				echo "📦 Staging local changes..."
				git add .

				echo "💾 Stashing local changes..."
				git stash

				echo "🔄 Fetching from remote..."
				git fetch origin

				set branch (git branch --show-current)
				echo "🌿 Current branch: $branch"

				echo "📝 Latest commit on origin/$branch:"
				git log origin/$branch -1 --oneline

				set local_commit (git rev-parse HEAD)
				set remote_commit (git rev-parse origin/$branch)

				if test "$local_commit" = "$remote_commit"
					echo "✅ Already up to date, nothing to rebase."
				else
					echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
					set conflicts (git rebase -X ours origin/$branch 2>&1)
					if test $status -eq 0
						echo "✅ Rebase successful."
					else
						echo "⚠️  Rebase had conflicts, local changes were preferred:"
						echo $conflicts
					end
				end

				echo "📂 Restoring stashed changes..."
				git stash pop; or echo "ℹ️  Nothing to restore from stash."

				read -P "🔨 Run nixos-rebuild switch now? [Y/n] " do_rebuild
				if test -z "$do_rebuild"; or test "$do_rebuild" = "y" -o "$do_rebuild" = "Y"
					echo "🔨 Rebuilding NixOS..."
					sudo nixos-rebuild switch --flake /etc/nixos#$host

					echo "✅ Done!"

					read -P "Reboot, poweroff, or do nothing? [r/p/N] " post_action
					switch "$post_action"
						case r R
							echo "🔁 Rebooting..."
							reboot
						case p P
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
				echo "📦 Staging local changes..."
				git add .

				echo "💾 Stashing local changes..."
				git stash

				echo "🔄 Fetching from remote..."
				git fetch origin

				set branch (git branch --show-current)
				echo "🌿 Current branch: $branch"

				echo "📝 Latest commit on origin/$branch:"
				git log origin/$branch -1 --oneline

				set local_commit (git rev-parse HEAD)
				set remote_commit (git rev-parse origin/$branch)

				if test "$local_commit" = "$remote_commit"
					echo "✅ Already up to date, nothing to rebase."
				else
					echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
					set conflicts (git rebase -X ours origin/$branch 2>&1)
					if test $status -eq 0
						echo "✅ Rebase successful."
					else
						echo "⚠️  Rebase had conflicts, local changes were preferred:"
						echo $conflicts
					end
				end

				echo "📂 Restoring stashed changes..."
				git stash pop; or echo "ℹ️  Nothing to restore from stash."

				echo "✅ Done!"
			'';
		};
	};


}
