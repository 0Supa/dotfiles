# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-stable,
  pkgs-wayland,
  callPackage,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        # memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "vm.swappiness" = 1;
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "100%";
    };
  };

  fileSystems = {
    "/".options = [
      "relatime"
      "lazytime"
      "commit=60"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  networking = {
    hostName = "Kappa";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  time.timeZone = "Europe/Bucharest";

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ro_RO.UTF-8/UTF-8"
    ];

    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_TIME = "ro_RO.UTF-8";
    };
  };

  # console.catppuccin.enable = true;

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
      ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };

    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    # logitech.wireless.enable = true;
  };

  security = {
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };

    sudo.enable = false;
    rtkit.enable = true;
  };

  services = {
    xserver = {
      enable = true;

      videoDrivers = [ "nvidia" ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''${lib.getExe pkgs.greetd.tuigreet} --time --cmd "sway --unsupported-gpu"'';
          user = "supa";
        };
      };
    };

    # cron = {
    #   enable = true;
    #   systemCronJobs = [
    #     # Send a message to turn off headphones rgb every minute
    #     "* * * * *  root  ${lib.getExe pkgs.headsetcontrol} -l 0"
    #   ];
    # };

    gvfs.enable = true;
    blueman.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users = {
      supa = {
        isNormalUser = true;
        description = "Supa";
        extraGroups = [
          "wheel"
          "gamemode"
        ];
        # upkg
        packages = with pkgs; [
          # Internet
          librewolf
          chromium
          firefox
          technorino
          pkgs-stable.electrum # BTC wallet
          # monero-gui # XMR wallet
          qbittorrent
          soulseekqt
          webcord-vencord
          thunderbird
          discord

          # Utils/Misc
          kitty # Terminal
          foot
          fastfetch
          yt-dlp
          pavucontrol # Volume control
          keepassxc # Password manager
          flameshot # Screenshots
          songrec # Shazam song recognition
          scrcpy
          filezilla
          curlie
          gnupg
          session-desktop
          dbgate
          libreoffice

          # Dev
          vscode
          github-desktop
          helix
          insomnia
          gh
          lazygit
          rustc
          cargo
          # LSP
          gopls
          typescript-language-server
          nil
          nixfmt-rfc-style
          php

          # Multimedia
          nsxiv # Image viewer
          mpv
          jellyfin-mpv-shim
          jellyfin-rpc
          spotify
          obs-studio
          audacity
          imagemagick

          # Games
          prismlauncher # Minecraft launcher
        ];
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-extra
      noto-fonts-color-emoji
      noto-fonts-emoji
      # corefonts
      font-awesome
      iosevka
      open-dyslexic
      powerline-symbols
      fantasque-sans-mono
      inter
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Fantasque Sans Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [
          "Noto Sans"
          "Noto Color Emoji"
        ];
      };
    };
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # firefox.enable = true;

    zsh.enable = true;

    steam.enable = true;
    gamemode.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    file-roller.enable = true;
  };

  virtualisation.docker.enable = true;

  environment = {
    systemPackages = with pkgs; [
      # Essential
      vim
      wget
      git
      xz
      htop
      bottom
      nvitop
      go
      nodejs
      zbar
      playerctl
      autorandr
      scrot
      psmisc
      ffmpeg-full
      compsize
      pkg-config
      zulu8
      zulu17
      ripgrep
      config.boot.kernelPackages.cpupower
      busybox
      libclang
      grim
      slurp
      wl-clipboard
      mako
      nvidia-vaapi-driver
      dig

      (pkgs.writeShellScriptBin "c2" ''
        export QT_QPA_PLATFORM=xcb
        exec ${lib.getExe technorino} "$@"
      '')
    ];

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.librewolf}";
      EDITOR = "${lib.getExe pkgs.helix}";

      # NIXOS_OZONE_WL = "1"; # causes flickering in electron apps
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };

  nix = {
    package = pkgs.lix;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [
        "root"
        "supa"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      pkgs-wayland.overlay

      (final: prev: {
        foot = pkgs-stable.foot;
      })

      (final: prev: {
        technorino = prev.chatterino7.overrideAttrs (oldAttrs: {
          pname = "technorino";
          version = "nightly";

          buildInputs =
            oldAttrs.buildInputs
            ++ (with prev; [
              kdePackages.qtimageformats
              libnotify
            ]);
          src = final.chatterino7.src.override {
            owner = "2547techno";
            repo = "technorino";
            tag = null;
            rev = "ca72ecfcc8db40c16051adf7c426a01eaffd5c6c";
            hash = "sha256-pG96nAyjEtfeOCkhG5rTs1g3Vq4lXHpLSDq0Tr196wQ=";
          };
        });
      })
    ];
  };

  system.stateVersion = "24.05"; # do not change
}
