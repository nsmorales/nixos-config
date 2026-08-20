{ config, inputs, lib, pkgs, ... }:

let
  user = "nmorales";
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let path = ../../overlays; in with builtins;
      map (n: import (path + ("/" + n)))
        (filter
          (n: match ".*\\.nix" n != null ||
            pathExists (path + ("/" + n + "/default.nix")))
          (attrNames (readDir path)));
  };

  nix = {
    package = pkgs.nix;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "@admin" "${user}" ];
      allowed-users = [ "${user}" ];
    };

    # Pin the flake registry and <nixpkgs> to this flake's nixpkgs input
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
