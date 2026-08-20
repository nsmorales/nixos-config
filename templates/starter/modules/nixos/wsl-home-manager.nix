{ config, pkgs, lib, ... }:

let
  user = "nmorales";
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  # Shared programs (zsh+omz+p10k, git, vim, ghostty, tmux, ssh)
  imports = [ ../shared/home-manager.nix ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = user;
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files;
    stateVersion = "26.05";
  };
}
