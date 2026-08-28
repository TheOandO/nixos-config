{ config, pkgs, ... }:
{
	programs.fish = {
		interactiveShellInit = ''
 	    	fastfetch
 	    	set fish_greeting ""
		'';

		functions = {
			rebuild = ''
				cd /etc/nixos

				set host (hostname)

				echo "🔄 Updating flake inputs..."
				sudo nix flake update

				echo "📦 Staging local changes..."
				sudo git add .

				read -P "Commit message (leave empty for default): " msg
				if test -z "$msg"
					set msg "update: "(date +%Y-%m-%d)
				end
				set msg "[$host] $msg"

				echo "💾 Committing changes..."
				sudo git commit -m "$msg"; or true

				echo "🔄 Fetching from remote..."
				sudo git fetch origin

				echo "⚡ Rebasing with local changes taking priority..."
				sudo git rebase -X ours origin/(sudo git branch --show-current); or true

				echo "⬆️  Force pushing to remote..."
				sudo git push --force

				echo "🔨 Rebuilding NixOS (with upgrades)..."
				sudo nixos-rebuild switch --upgrade-all --flake .#$host

				echo "✅ Done!"
			'';
			pull-nix = ''
				cd /etc/nixos

				set host (hostname)

				echo "📦 Staging local changes..."
				sudo git add .

				echo "💾 Stashing local changes..."
				sudo git stash

				echo "🔄 Fetching from remote..."
				sudo git fetch origin

				set branch (sudo git branch --show-current)
				echo "🌿 Current branch: $branch"

				set local_commit (sudo git rev-parse HEAD)
				set remote_commit (sudo git rev-parse origin/$branch)

				if test "$local_commit" = "$remote_commit"
					echo "✅ Already up to date, nothing to rebase."
				else
					echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
					set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
					if test $status -eq 0
						echo "✅ Rebase successful."
					else
						echo "⚠️  Rebase had conflicts, local changes were preferred:"
						echo $conflicts
					end
				end

				echo "📂 Restoring stashed changes..."
				sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."

				echo "🔨 Rebuilding NixOS..."
				sudo nixos-rebuild switch --flake /etc/nixos#$host

				echo "✅ Done!"
			'';
			pull-dot = ''
				cd ~/.config
				echo "📦 Staging local changes..."
				sudo git add .

				echo "💾 Stashing local changes..."
				sudo git stash

				echo "🔄 Fetching from remote..."
				sudo git fetch origin

				set branch (sudo git branch --show-current)
				echo "🌿 Current branch: $branch"

				set local_commit (sudo git rev-parse HEAD)
				set remote_commit (sudo git rev-parse origin/$branch)

				if test "$local_commit" = "$remote_commit"
					echo "✅ Already up to date, nothing to rebase."
				else
					echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
					set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
					if test $status -eq 0
						echo "✅ Rebase successful."
					else
						echo "⚠️  Rebase had conflicts, local changes were preferred:"
						echo $conflicts
					end
				end

				echo "📂 Restoring stashed changes..."
				sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."

				echo "✅ Done!"
			'';
		};
	}


}
