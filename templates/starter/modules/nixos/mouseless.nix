{ ... }:

{
  # Flatpak support (for Mouseless: flatpak install sonuscape net.sonuscape.mouseless)
  # Requires xdg.portal.enable = true (set in hosts/nixos/default.nix).
  services.flatpak.enable = true;

  # Wayland input access for Mouseless.
  # NOTE: group-based udev permissions (uinput/input groups) do NOT work inside
  # the Flatpak sandbox — supplementary groups are unmapped in its user
  # namespace. Ownership by uid is required (vendor Method 2, tmpfiles).
  # This relaxes Wayland's keyboard/mouse restrictions for the whole session.
  hardware.uinput.enable = true;

  # Owner uid grants the Flatpak sandbox access (groups are unmapped there);
  # group uinput/input keeps keyd's supplementary-group access working.
  systemd.tmpfiles.rules = [
    "z /dev/uinput 0660 nmorales uinput - -"
    "z /dev/input/event* 0660 nmorales input - -"
  ];
}
