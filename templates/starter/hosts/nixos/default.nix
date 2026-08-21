{ config, inputs, pkgs, ... }:

let
  user = "nmorales";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared
    # disk-config.nix is used only during fresh installs via the install script (disko).
    # Do not import it here — it conflicts with hardware-configuration.nix on running systems.
  ];

  # Use the systemd-boot EFI boot loader.
  # Hardware modules (initrd, filesystems) are owned by hardware-configuration.nix
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Nix settings (caches, keys, features, users) are defined in modules/shared
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
  };

  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    zsh.enable = true;

    # Run precompiled, non-Nix binaries (e.g. mise-installed tools)
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        openssl
        zlib
        ncurses
      ];
    };

    # Hyprland compositor
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true; # Use UWSM for proper systemd session management
    };
  };

  # XDG portal for Hyprland (screen share, file picker, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  services = {
    # Display manager: greetd + tuigreet
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # start-hyprland is Hyprland's session launcher (handles systemd env import)
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'start-hyprland'";
          user = "greeter";
        };
      };
    };

    # PipeWire for audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth
    blueman.enable = true;

    # Better support for general peripherals
    libinput.enable = true;

    # Let's be able to SSH into this machine
    openssh.enable = true;

    # Sync state between machines
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/${user}/.local/share/syncthing";
      configDir = "/home/${user}/.config/syncthing";
      user = "${user}";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = { };
        options.globalAnnounceEnabled = false; # Only sync on LAN
      };
    };

    # Enable CUPS to print documents
    # printing.enable = true;
    # printing.drivers = [ pkgs.brlaser ]; # Brother printer driver
  };

  # Disable PulseAudio (we use PipeWire)
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit apps (Steam, Wine, etc.)
    };
    amdgpu = {
      initrd.enable = true; # Early KMS for faster boot / better Wayland startup
      opencl.enable = true; # OpenCL compute support
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    # Crypto wallet support
    ledger.enable = true;
  };

  # Security: PAM for Hyprlock screen locker
  security = {
    pam.services.hyprlock = { };
    rtkit.enable = true; # Required for PipeWire real-time priority
  };

  # Add docker daemon
  virtualisation = {
    docker = {
      enable = true;
      logDriver = "json-file";
    };
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable 'sudo' for the user
        "docker"
        "networkmanager"
        "video"
        "audio"
        "input"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = sshKeys;
    };

    root = {
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = import ../../modules/shared/fonts.nix { inherit pkgs; };

  environment.systemPackages = with pkgs; [
    gitFull
    inetutils
    tuigreet
  ];

  system.stateVersion = "26.05";
}
