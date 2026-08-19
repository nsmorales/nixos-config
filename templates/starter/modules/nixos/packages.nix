{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [

  # Security and authentication
  yubikey-agent

  # App and package management
  appimage-run
  gnumake
  cmake
  home-manager

  # Fonts
  fontconfig

  # Audio tools
  pavucontrol    # Volume/audio control GUI
  playerctl      # Media player control (play/pause/next/prev)
  brightnessctl  # Screen brightness control

  # Wayland / display tools
  grim           # Screenshot tool (Wayland)
  slurp          # Region selection for screenshots
  hyprpaper      # Wallpaper daemon for Hyprland
  hyprlock       # Screen locker for Hyprland
  wdisplays      # Display configuration GUI (Wayland)
  wev            # Wayland event viewer (debug input)
  kanshi         # Automatic display configuration

  # Application launcher & bar
  wofi
  waybar

  # Notifications
  libnotify

  # Network manager applet (system tray)
  networkmanagerapplet

  # File management
  pcmanfm        # GUI file manager
  xdg-utils      # xdg-open and friends

  # System utilities
  inotify-tools  # inotifywait, inotifywatch
  sqlite
  ncurses        # Provides tmux-256color terminfo for true color

  # AMD GPU — RADV (Mesa Vulkan driver) is enabled by default via hardware.graphics

  # Browsers
  firefox
  google-chrome

  # PDF viewer
  zathura
]
