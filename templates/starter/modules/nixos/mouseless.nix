{ ... }:

{
  # Flatpak support (for Mouseless: flatpak install sonuscape net.sonuscape.mouseless)
  # Requires xdg.portal.enable = true (set in hosts/nixos/default.nix).
  services.flatpak.enable = true;

  # Wayland input access for Mouseless: /dev/uinput for virtual device creation.
  # Relaxes Wayland's keyboard/mouse restrictions for the whole user session.
  # Creates the `uinput` group and udev rule (root:uinput, 0660); the user must
  # be a member — see extraGroups in hosts/nixos/default.nix.
  # Also enabled transitively by services.keyd (mkDefault), so this is idempotent.
  hardware.uinput.enable = true;
}
