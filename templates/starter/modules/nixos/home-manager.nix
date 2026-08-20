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
    stateVersion = "26.05";
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
    # Pin to hyprlang (.conf) format. The new Lua format (default in HM 26.05)
    # requires a completely different settings syntax — migrate when ready.
    configType = "hyprlang";
    settings = {
      # Monitor configuration — adjust to your display
      # See: https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [ ",preferred,auto,1" ];

      # Autostart
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.hyprpaper}/bin/hyprpaper"
        "${pkgs.dunst}/bin/dunst"
        "${pkgs.udiskie}/bin/udiskie --tray"
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
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
        # Ensure Nix profile binaries and setuid wrappers (sudo) are in PATH
        "PATH,\$HOME/.nix-profile/bin:/etc/profiles/per-user/nmorales/bin:/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:\$PATH"
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
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = "rgba(1a1a1aee)";
        };
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

      bind = [
        # Applications
        "SUPER, Return, exec, ${pkgs.ghostty}/bin/ghostty"
        "SUPER, Space, exec, ${pkgs.wofi}/bin/wofi --show drun"
        "SUPER, E, exec, ${pkgs.ghostty}/bin/ghostty -e ${pkgs.yazi}/bin/yazi"
        "SUPER, B, exec, firefox"
        "SUPER SHIFT, Q, killactive"
        "SUPER SHIFT, E, exit"
        "SUPER, F, fullscreen, 0"
        "SUPER SHIFT, F, togglefloating"
        "SUPER, P, pseudo"
        "SUPER, J, togglesplit"

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"

        # Focus movement (vim-style)
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"

        # Window movement
        "SUPER SHIFT, H, movewindow, l"
        "SUPER SHIFT, L, movewindow, r"
        "SUPER SHIFT, K, movewindow, u"
        "SUPER SHIFT, J, movewindow, d"

        # Workspaces
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"

        # Move window to workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"

        # Scroll through workspaces
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ];

      # Mouse binds
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
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

  programs = shared-programs // {

  # Waybar
  waybar = {
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
  wofi = {
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

  # Firefox with declarative extensions via NUR
  firefox = {
    enable = true;
    profiles.nmorales = {
      isDefault = true;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        surfingkeys
        ublacklist
        simple-tab-groups
        darkreader
        leechblock-ng
        youtube-recommended-videos  # Unhook: Remove YouTube recommended
      ];
      settings = {
        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true; # Hardware video decode
        # Privacy
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        # UI
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
      };
    };
  };

  }; # end programs

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

}
