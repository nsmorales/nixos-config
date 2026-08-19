{ config, inputs, pkgs, ... }:

let
  user = "nmorales";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/shared
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    # Uncomment for AMD GPU
    # initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  networking = {
    hostName = "%HOST%";
    networkmanager.enable = true;
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    zsh.enable = true;

    # Hyprland compositor
    hyprland = {
      enable = true;
      xwayland.enable = true;
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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
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
        devices = {};
        options.globalAnnounceEnabled = false; # Only sync on LAN
      };
    };

    # Enable CUPS to print documents
    # printing.enable = true;
    # printing.drivers = [ pkgs.brlaser ]; # Brother printer driver
  };

  # Disable PulseAudio (we use PipeWire)
  hardware = {
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    # Uncomment for AMD GPU
    # hardware.amdgpu.enable = true;

    # Crypto wallet support
    ledger.enable = true;
  };

  # Security: PAM for Hyprlock screen locker
  security = {
    pam.services.hyprlock = {};
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
        "wheel"    # Enable 'sudo' for the user
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

  fonts.packages = with pkgs; [
    dejavu_fonts
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ];

  environment.systemPackages = with pkgs; [
    gitFull
    inetutils
    greetd.tuigreet
  ];

  system.stateVersion = "26.05";
}
