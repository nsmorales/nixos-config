{ user, pkgs, ... }:

let
  home           = "/home/${user}";
  xdg_configHome = "${home}/.config";
  xdg_dataHome   = "${home}/.local/share";
in
{
  # Hyprpaper wallpaper configuration
  # Place a wallpaper image at ~/.config/hypr/wallpaper.jpg (or update path below)
  "${xdg_configHome}/hypr/hyprpaper.conf" = {
    text = ''
      # Preload and set wallpaper
      # Update the path to point to your wallpaper file
      # preload = ${home}/.config/hypr/wallpaper.jpg
      # wallpaper = ,${home}/.config/hypr/wallpaper.jpg

      splash = false
    '';
  };

  # Power/session management script (wofi-based)
  "${xdg_configHome}/hypr/scripts/powermenu.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      options=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

      chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power" --width 300 --height 220)

      case "$chosen" in
        " Lock")
          hyprlock
          ;;
        " Logout")
          hyprctl dispatch exit
          ;;
        " Suspend")
          systemctl suspend
          ;;
        " Reboot")
          systemctl reboot
          ;;
        " Shutdown")
          systemctl poweroff
          ;;
      esac
    '';
  };

  # Screenshot helper script
  "${xdg_configHome}/hypr/scripts/screenshot.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Usage: screenshot.sh [full|area|window]
      SCREENSHOT_DIR="${xdg_dataHome}/Pictures/Screenshots"
      mkdir -p "$SCREENSHOT_DIR"
      FILENAME="$SCREENSHOT_DIR/$(date +%Y%m%d-%H%M%S).png"

      case "$1" in
        full)
          grim "$FILENAME" && notify-send "Screenshot" "Saved to $FILENAME"
          ;;
        area)
          grim -g "$(slurp)" "$FILENAME" && notify-send "Screenshot" "Saved to $FILENAME"
          ;;
        *)
          # Default: area selection, also copy to clipboard
          grim -g "$(slurp)" - | tee "$FILENAME" | wl-copy \
            && notify-send "Screenshot" "Copied to clipboard and saved to $FILENAME"
          ;;
      esac
    '';
  };
}
