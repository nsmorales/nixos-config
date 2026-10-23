{ config, pkgs, lib, ... }:

let
  user = "nmorales";
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  # Shared programs (zsh+omz+p10k, git, vim, ghostty, tmux, ssh)
  imports = [ ../shared/home-manager.nix ];

  # Attach to tmux when WSL launches a shell.
  # Skips nested shells inside tmux and non-interactive shells.
  # Attach-first so extra terminal tabs never race the server startup —
  # tmux-continuum silently disables auto-saving when it sees multiple
  # tmux processes (clients included) while the server is starting.
  # mkAfter so this runs after oh-my-zsh and plugins are initialized.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -z "$TMUX" && $- == *i* ]]; then
      exec tmux attach -t default 2>/dev/null || exec tmux new-session -A -s default
    fi
  '';

  # Run the tmux server as a systemd user service so it starts at WSL boot
  # (users.users.<name>.linger keeps user@1000 alive) with zero clients
  # attached. That keeps tmux-continuum's "another server" heuristic happy
  # (auto-save and auto-restore enable correctly), and the server survives
  # opening/closing terminal windows and individual session churn.
  systemd.user.services.tmux-server = {
    Unit.Description = "tmux server";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux -u new-session -A -d -s default";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
      Restart = "always";
      RestartSec = "2";
    };
  };

  # Keep the server alive when the last session exits, so shells can always
  # re-attach instead of starting a competing server themselves.
  programs.tmux.extraConfig = lib.mkAfter ''
    # Persist the tmux server even when the last session closes
    set -g exit-empty off
  '';

  home = {
    enableNixpkgsReleaseCheck = false;
    username = user;
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files;
    stateVersion = "26.05";
  };
}
