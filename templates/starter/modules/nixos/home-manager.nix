{ config, pkgs, lib, ... }:

let
  user = "nmorales";
  xdg_configHome = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix { inherit user pkgs; };
    stateVersion = "25.05";
  };

  # GTK theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Hyprland window manager (declarative config via home-manager)
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration — adjust to your display
      # See: https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [ ",preferred,auto,1" ];

      # Autostart
      exec-once = [
        "waybar"
        "hyprpaper"
        "dunst"
        "udiskie --tray"
        "nm-applet --indicator"
      ];

      # Environment variables for Wayland compatibility
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      input = {
        kb_layout = "us";
        kb_options = "ctrl:nocaps"; # Caps Lock → Ctrl
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(6699ccee) rgba(c594c5ee) 45deg";
        "col.inactive_border" = "rgba(65737e88)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
        };
        drop_shadow = true;
        shadow_range = 8;
        shadow_render_power = 2;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "easeInOutCubic, 0.65, 0, 0.35, 1"
        ];
        animation = [
          "windows, 1, 4, easeOutCubic"
          "windowsOut, 1, 4, easeOutCubic, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 4, default"
          "workspaces, 1, 4, easeInOutCubic"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      # Key bindings — $mainMod = Super (Windows key)
      "$mainMod" = "SUPER";

      bind = [
        # Applications
        "$mainMod, Return, exec, ghostty"
        "$mainMod, Space, exec, wofi --show drun"
        "$mainMod, E, exec, ghostty -e yazi"
        "$mainMod, B, exec, firefox"
        "$mainMod SHIFT, Q, killactive"
        "$mainMod SHIFT, E, exit"
        "$mainMod, F, fullscreen, 0"
        "$mainMod SHIFT, F, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"

        # Focus movement (vim-style)
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Window movement
        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Media / volume keys
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Window rules
      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "center, class:^(pavucontrol)$"
        "size 800 600, class:^(pavucontrol)$"
      ];
    };
  };

  # Waybar
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "battery"
        "clock"
        "tray"
      ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          urgent = "";
          active = "";
          default = "";
        };
      };

      "hyprland/window" = {
        max-length = 60;
      };

      cpu = {
        format = " {usage}%";
        tooltip = false;
      };

      memory = {
        format = " {}%";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      network = {
        format-wifi = " {essid} ({signalStrength}%)";
        format-ethernet = " {ifname}";
        format-disconnected = "⚠ Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = " Muted";
        format-icons = {
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };

      clock = {
        format = " {:%H:%M}";
        format-alt = " {:%A, %B %d, %Y}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      tray = {
        spacing = 8;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(31, 37, 40, 0.92);
        color: #c0c5ce;
        border-bottom: 2px solid rgba(102, 153, 204, 0.5);
      }

      #workspaces button {
        padding: 0 8px;
        color: #65737e;
        background: transparent;
        border: none;
      }

      #workspaces button.active {
        color: #6699cc;
        background: rgba(102, 153, 204, 0.15);
        border-bottom: 2px solid #6699cc;
      }

      #workspaces button.urgent {
        color: #ec5f67;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #submap {
        padding: 0 12px;
        color: #c0c5ce;
      }

      #battery.warning {
        color: #fac863;
      }

      #battery.critical {
        color: #ec5f67;
        animation: blink 0.5s steps(1) infinite;
      }

      @keyframes blink {
        to { color: #1f2528; background-color: #ec5f67; }
      }

      #window {
        color: #99c794;
      }
    '';
  };

  # wofi launcher
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
    };
    style = ''
      window {
        margin: 0px;
        background-color: #1f2528;
        border: 2px solid #6699cc;
        border-radius: 8px;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      #input {
        padding: 8px 16px;
        color: #c0c5ce;
        background-color: #1f2528;
        border: none;
        border-bottom: 1px solid #65737e;
        border-radius: 0;
      }

      #inner-box {
        background-color: #1f2528;
      }

      #outer-box {
        margin: 0;
        padding: 4px;
        background-color: #1f2528;
      }

      #entry {
        padding: 4px 8px;
        border-radius: 4px;
        color: #c0c5ce;
      }

      #entry:selected {
        background-color: rgba(102, 153, 204, 0.2);
        color: #6699cc;
      }

      #text {
        padding: 0 4px;
      }
    '';
  };

  # Dunst notification daemon (Wayland compatible)
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 320;
        height = 400;
        offset = "16x48";
        origin = "top-right";
        padding = 16;
        horizontal_padding = 16;
        border_width = 1;
        corner_radius = 8;
        frame_width = 1;
        frame_color = "#6699cc";
        separator_height = 1;
        separator_color = "#65737e";
        sort = "no";
        idle_threshold = 120;
        font = "JetBrainsMono Nerd Font 11";
        line_height = 4;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = false;
        hide_duplicate_count = "yes";
        show_indicators = "no";
        icon_position = "left";
        max_icon_size = 48;
        sticky_history = "yes";
        history_length = 20;
      };

      urgency_low = {
        background = "#1f2528";
        foreground = "#c0c5ce";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1f2528";
        foreground = "#c0c5ce";
        timeout = 8;
      };

      urgency_critical = {
        background = "#ec5f67";
        foreground = "#1f2528";
        frame_color = "#ec5f67";
        timeout = 0;
      };
    };
  };

  # Auto-mount devices
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  programs = shared-programs // {};
}
