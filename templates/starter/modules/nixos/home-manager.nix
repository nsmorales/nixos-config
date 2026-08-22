{ config, pkgs, lib, ... }:

let
  user = "nmorales";

  # External monitor matched by description (see `hyprctl monitors all`)
  mainMonitorDesc = "Samsung Electric Company LC34G55T H1AK500000";

  shared-files = import ../shared/files.nix { inherit config pkgs; };

  lua = lib.generators.mkLuaInline;
  hlBind = keys: dispatcher: { _args = [ keys (lua dispatcher) ]; };
  hlBindFlags = keys: dispatcher: flags: { _args = [ keys (lua dispatcher) flags ]; };

  # Nerd Font icon by unicode codepoint (keeps this file ASCII-only).
  # Browse icons at https://www.nerdfonts.com/cheat-sheet
  nf = hex: builtins.fromJSON ''"\u${hex}"'';

in
{
  imports = [ ../shared/home-manager.nix ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
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
  # Lua config format (Hyprland 0.55+, hyprlang is deprecated)
  # See: https://wiki.hypr.land/Configuring/Start/
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = {
      # Monitor configuration — external (matched by description) is primary at 0x0;
      # everything else (laptop panel) extends to its right. When the external is
      # absent, the fallback rule applies and the panel sits at 0x0.
      # See: https://wiki.hypr.land/Configuring/Basics/Monitors/
      monitor = [
        {
          output = "desc:${mainMonitorDesc}";
          mode = "3440x1440@59.97";
          position = "0x0";
          scale = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto-right";
          scale = 1;
        }
      ];

      # Autostart + monitor hotplug. Each list entry becomes an hl.on(...) call;
      # apply_main_monitor is defined in extraConfig below.
      # See: https://wiki.hypr.land/Configuring/Basics/Autostart/
      on = [
        {
          _args = [
            "hyprland.start"
            (lua ''
              function()
                hl.exec_cmd("${pkgs.waybar}/bin/waybar")
                hl.exec_cmd("${pkgs.hyprpaper}/bin/hyprpaper")
                hl.exec_cmd("${pkgs.dunst}/bin/dunst")
                hl.exec_cmd("${pkgs.udiskie}/bin/udiskie --tray")
                hl.exec_cmd("${pkgs.networkmanagerapplet}/bin/nm-applet --indicator")
                apply_main_monitor()
              end
            '')
          ];
        }
        {
          _args = [
            "monitor.added"
            (lua ''function() apply_main_monitor() end'')
          ];
        }
        {
          _args = [
            "monitor.removed"
            (lua ''function() apply_main_monitor() end'')
          ];
        }
      ];

      # Environment variables for Wayland compatibility
      # $VAR references require os.getenv() — no shell expansion in hl.env
      env = [
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "XCURSOR_THEME" "Adwaita" ]; }
        { _args = [ "GDK_BACKEND" "wayland,x11" ]; }
        { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
        { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
        { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
        { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
        { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
        { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
        {
          # Ensure Nix profile binaries and setuid wrappers (sudo) are in PATH
          _args = [
            "PATH"
            (lua ''
              (os.getenv("HOME") or "") .. "/.nix-profile/bin:/etc/profiles/per-user/${user}/bin:/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:" .. (os.getenv("PATH") or "")
            '')
          ];
        }
      ];

      # Config variables
      # See: https://wiki.hypr.land/Configuring/Basics/Variables/
      config = {
        input = {
          kb_layout = "us";
          kb_options = "ctrl:nocaps"; # Caps Lock → Ctrl
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
          };
        };

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          col = {
            active_border = {
              colors = [ "rgba(6699ccee)" "rgba(c594c5ee)" ];
              angle = 45;
            };
            inactive_border = "rgba(65737e88)";
          };
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

        animations.enabled = true;

        dwindle = {
          preserve_split = true;
          smart_resizing = true;
          force_split = 0;
        };

        gestures = {
          workspace_swipe_touch = true;
          workspace_swipe_touch_invert = false;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };
      };

      # Animation curves
      # See: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
      curve = [
        {
          _args = [
            "easeOutCubic"
            { type = "bezier"; points = [ [ 0.33 1 ] [ 0.68 1 ] ]; }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            { type = "bezier"; points = [ [ 0.65 0 ] [ 0.35 1 ] ]; }
          ];
        }
      ];

      animation = [
        { leaf = "windows"; enabled = true; speed = 4; bezier = "easeOutCubic"; }
        { leaf = "windowsOut"; enabled = true; speed = 4; bezier = "easeOutCubic"; style = "popin 80%"; }
        { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "fade"; enabled = true; speed = 4; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 4; bezier = "easeInOutCubic"; }
      ];

      # Keybinds
      # See: https://wiki.hypr.land/Configuring/Basics/Binds/
      bind = [
        # Applications
        (hlBind "SUPER + Return" ''hl.dsp.exec_cmd("${pkgs.ghostty}/bin/ghostty")'')
        (hlBind "SUPER + space" ''hl.dsp.exec_cmd("${pkgs.wofi}/bin/wofi --show drun")'')
        (hlBind "SUPER + E" ''hl.dsp.exec_cmd("${pkgs.ghostty}/bin/ghostty -e ${pkgs.yazi}/bin/yazi")'')
        (hlBind "SUPER + B" ''hl.dsp.exec_cmd("firefox")'')
        (hlBind "SUPER + SHIFT + Q" "hl.dsp.window.close()")
        (hlBind "SUPER + SHIFT + E" ''hl.dsp.exec_cmd("uwsm stop")'')
        (hlBind "SUPER + F" "hl.dsp.window.fullscreen()")
        (hlBind "SUPER + SHIFT + F" ''hl.dsp.window.float({ action = "toggle" })'')
        (hlBind "SUPER + T" ''hl.dsp.layout("togglesplit")'')

        # Screenshot
        (hlBind "Print" ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy")'')
        (hlBind "SUPER + SHIFT + S" ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")'')

        # Focus movement (vim-style)
        (hlBind "SUPER + H" ''hl.dsp.focus({ direction = "l" })'')
        (hlBind "SUPER + L" ''hl.dsp.focus({ direction = "r" })'')
        (hlBind "SUPER + K" ''hl.dsp.focus({ direction = "u" })'')
        (hlBind "SUPER + J" ''hl.dsp.focus({ direction = "d" })'')

        # Window movement
        (hlBind "SUPER + SHIFT + H" ''hl.dsp.window.move({ direction = "l" })'')
        (hlBind "SUPER + SHIFT + L" ''hl.dsp.window.move({ direction = "r" })'')
        (hlBind "SUPER + SHIFT + K" ''hl.dsp.window.move({ direction = "u" })'')
        (hlBind "SUPER + SHIFT + J" ''hl.dsp.window.move({ direction = "d" })'')

        # Scroll through workspaces
        (hlBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (hlBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

        # Move/resize windows with SUPER + LMB/RMB drag
        (hlBindFlags "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (hlBindFlags "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

        # Media / volume keys (locked = active on lockscreen, repeating = repeat while held)
        (hlBindFlags "XF86AudioRaiseVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")''
          { locked = true; repeating = true; })
        (hlBindFlags "XF86AudioLowerVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")''
          { locked = true; repeating = true; })
        (hlBindFlags "XF86MonBrightnessUp"
          ''hl.dsp.exec_cmd("brightnessctl set 10%+")''
          { locked = true; repeating = true; })
        (hlBindFlags "XF86MonBrightnessDown"
          ''hl.dsp.exec_cmd("brightnessctl set 10%-")''
          { locked = true; repeating = true; })

        (hlBindFlags "XF86AudioMute"
          ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")''
          { locked = true; })
        (hlBindFlags "XF86AudioPlay"
          ''hl.dsp.exec_cmd("playerctl play-pause")''
          { locked = true; })
        (hlBindFlags "XF86AudioNext"
          ''hl.dsp.exec_cmd("playerctl next")''
          { locked = true; })
        (hlBindFlags "XF86AudioPrev"
          ''hl.dsp.exec_cmd("playerctl previous")''
          { locked = true; })
      ]
      ++ (map
        (n: hlBind "SUPER + ${toString n}" "hl.dsp.focus({ workspace = ${toString n} })")
        (lib.range 1 8))
      ++ (map
        (n: hlBind "CTLR + ${toString n}" "hl.dsp.focus({ workspace = ${toString n} })")
        (lib.range 1 8))
      ++ (map
        (n: hlBind "SUPER + SHIFT + ${toString n}" "hl.dsp.window.move({ workspace = ${toString n} })")
        (lib.range 1 8));

      # Window rules
      # See: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
      window_rule = [
        {
          match.class = "^pavucontrol$";
          float = true;
          center = true;
          size = [ 800 600 ];
        }
        { match.class = "^blueman-manager$"; float = true; }
        { match.class = "^nm-connection-editor$"; float = true; }
      ];
    };

    # Appended after the generated settings; globals resolve at call time,
    # so the hl.on handlers above can reference it.
    extraConfig = ''
      -- Promote the external monitor (matched by description) to main:
      -- move every workspace onto it and focus it. No-op when disconnected.
      function apply_main_monitor()
        local main
        for _, m in pairs(hl.get_monitors()) do
          if m.description and m.description:find("${mainMonitorDesc}", 1, true) then
            main = m
            break
          end
        end
        if not main then
          return
        end
        for _, ws in pairs(hl.get_workspaces()) do
          hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = main }))
        end
        hl.dispatch(hl.dsp.focus({ monitor = main }))
      end
    '';
  };

  programs = {

    # Waybar
    waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        height = 34;
        spacing = 0;

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
            "1" = nf "f120"; # terminal
            "2" = nf "f268"; # browser
            "3" = nf "f121"; # code
            "4" = nf "f07b"; # folder
            "5" = nf "f001"; # music
            "6" = nf "e70f"; # mail? fallback below if missing
            "7" = nf "f0f3"; # bell
            "8" = nf "f064"; # share
            urgent = nf "f06a"; # exclamation circle
            active = nf "f111"; # filled circle
            default = nf "f10c"; # hollow circle
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        cpu = {
          format = "${nf "f2db"} {usage}%"; # chip
          tooltip = false;
        };

        memory = {
          format = "${nf "f0a0"} {percentage}%"; # disk/stack
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "${nf "f0e7"} {capacity}%"; # bolt
          format-plugged = "${nf "f0e7"} {capacity}%";
          format-icons = [
            (nf "f244") # empty
            (nf "f243") # quarter
            (nf "f242") # half
            (nf "f241") # three-quarters
            (nf "f240") # full
          ];
        };

        network = {
          format-wifi = "${nf "f1eb"} {essid} ({signalStrength}%)"; # wifi
          format-ethernet = "${nf "f0ac"} {ifname}"; # globe
          format-disconnected = "${nf "f127"} Disconnected"; # broken link
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "${nf "f026"} Muted"; # volume-off
          format-icons = {
            default = [
              (nf "f026") # volume-off
              (nf "f027") # volume-down
              (nf "f028") # volume-up
            ];
          };
          on-click = "pavucontrol";
        };

        clock = {
          format = "${nf "f017"} {:%H:%M}"; # clock
          format-alt = "${nf "f017"} {:%A, %B %d, %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 8;
          icon-size = 14;
        };
      }];

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "Font Awesome 7 Free";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(31, 37, 40, 0.9);
          color: #c0c5ce;
          border-bottom: 2px solid rgba(102, 153, 204, 0.35);
        }

        #workspaces {
          background: rgba(101, 115, 126, 0.12);
          margin: 5px 0 5px 10px;
          padding: 0 4px;
          border-radius: 12px;
        }

        #workspaces button {
          padding: 0 6px;
          min-width: 20px;
          color: #65737e;
          background: transparent;
          border: none;
          border-radius: 10px;
        }

        #workspaces button:hover {
          background: rgba(102, 153, 204, 0.18);
          color: #c0c5ce;
        }

        #workspaces button.active {
          color: #1f2528;
          background: #6699cc;
        }

        #workspaces button.urgent {
          color: #1f2528;
          background: #ec5f67;
        }

        #submap {
          color: #fac863;
          margin: 0 8px;
        }

        #window {
          color: #99c794;
          font-weight: bold;
          margin: 0 12px;
        }

        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #battery,
        #clock {
          margin: 5px 0;
          padding: 0 12px;
          border-radius: 12px;
        }

        #pulseaudio {
          color: #5fb3b3;
          background: rgba(95, 179, 179, 0.10);
        }

        #network {
          color: #c594c5;
          background: rgba(197, 148, 197, 0.10);
        }

        #network.disconnected {
          color: #ec5f67;
          background: rgba(236, 95, 103, 0.10);
        }

        #cpu {
          color: #fac863;
          background: rgba(250, 200, 99, 0.10);
        }

        #memory {
          color: #f99157;
          background: rgba(249, 145, 87, 0.10);
        }

        #battery {
          color: #99c794;
          background: rgba(153, 199, 148, 0.10);
        }

        #battery.charging {
          color: #fac863;
        }

        #battery.warning {
          color: #1f2528;
          background: #fac863;
        }

        #battery.critical {
          color: #1f2528;
          background: #ec5f67;
          animation: blink 0.5s steps(1) infinite;
        }

        @keyframes blink {
          to { color: #ec5f67; background-color: #1f2528; }
        }

        #clock {
          color: #6699cc;
          background: rgba(102, 153, 204, 0.10);
          font-weight: bold;
        }

        #tray {
          margin: 5px 10px 5px 8px;
          padding: 0 6px;
        }
      '';
    };

    # Foot — lightweight Wayland terminal
    foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          dpi-aware = "no";
          pad = "6x6 center";
        };
        cursor.style = "beam";
        colors = {
          alpha = 0.95;
          background = "1b2b34";
          foreground = "c0c5ce";
          regular0 = "1b2b34";
          regular1 = "ec5f67";
          regular2 = "99c794";
          regular3 = "fac863";
          regular4 = "6699cc";
          regular5 = "c594c5";
          regular6 = "5fb3b3";
          regular7 = "c0c5ce";
          bright0 = "65737e";
          bright1 = "f99157";
          bright2 = "99c794";
          bright3 = "fac863";
          bright4 = "6699cc";
          bright5 = "c594c5";
          bright6 = "5fb3b3";
          bright7 = "ffffff";
          selection-background = "4f5b66";
          selection-foreground = "c0c5ce";
          urls = "6699cc";
        };
      };
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
          youtube-recommended-videos # Unhook: Remove YouTube recommended
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
