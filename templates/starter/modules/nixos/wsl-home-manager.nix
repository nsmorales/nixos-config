{ config, pkgs, lib, ... }:

let
  user = "nmorales";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = user;
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files;
    stateVersion = "26.05";
  };

  # All shared programs (zsh+omz+p10k, git, vim, ghostty, tmux, ssh)
  programs = shared-programs // {};
}
