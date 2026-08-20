{ config, pkgs, lib, ... }:

let
  user = "nmorales";
in {
  imports = [
    ../../../modules/shared
  ];

  # WSL-specific configuration
  wsl = {
    enable = true;
    defaultUser = user;
    startMenuLaunchers = true;
    # Enable WSLg for GUI app support (requires Windows 11 or Win10 with WSLg)
    # GUI apps like firefox can run via WSLg
    # nativeSystemd is always enabled in newer nixos-wsl
  };

  # Nix settings
  nix = {
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    package = pkgs.nix;
  };

  # No bootloader — Windows handles booting
  # No display manager — WSL starts a shell directly
  # No Hyprland/Wayland compositor — WSLg handles GUI

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  # SSH for connecting to WSL from Windows or remote
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Docker for development
  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # Fonts (for WSLg GUI apps)
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    gitFull
    wget
    curl
  ];

  # WSL doesn't use a traditional init, systemd is managed by NixOS-WSL
  system.stateVersion = "26.05";
}
