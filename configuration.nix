# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, inputs, pkgs, pkgs-stable, pkgs-wayland, callPackage, ... }:
{
  imports =
    [
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
    tmp = {
      useTmpfs = true;
      tmpfsSize = "100%";
    };
  };

  fileSystems = {
    "/".options = [ "relatime" "lazytime" "commit=60" ];
  };

  networking.hostName = "Kappa";

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

    # logitech.wireless.enable = true;
  };

  security = {
    doas = {
      enable = true;
      extraRules = [{
        groups = [ "wheel" ];
        keepEnv = true;
        persist = true;
      }];
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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"sway --unsupported-gpu\"";
          user = "supa";
        };
      };
    };

    cron = {
      enable = true;
      systemCronJobs = [
        # Send a message to turn off headphones rgb every minute
        "* * * * *  root  ${lib.getExe pkgs.headsetcontrol} -l 0"
      ];
    };

    gvfs.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users = {
      supa = {
        isNormalUser = true;
        description = "Supa";
        extraGroups = [ "wheel" "gamemode" ];
        packages = with pkgs; [
          # Internet
          chromium
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
          fastfetch
          yt-dlp
          pavucontrol # Volume control
          keepassxc # Password manager
          flameshot # Screenshots
          headsetcontrol # Used for disabling shitty RGB
          songrec # Shazam song recognition
          scrcpy
          filezilla
          curlie
          gnupg
          kleopatra
          session-desktop
          dbgate

          # Code
          vscodium
          nixpkgs-fmt # Used for nix formatting in vscode
          github-desktop
          helix
          insomnia

          # Multimedia
          nsxiv # Image viewer
          mpv
          spotify
          obs-studio
          audacity
          kdenlive
          jellyfin-media-player

          # Games
          prismlauncher # Minecraft launcher
        ];
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
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
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      };
    };
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    firefox.enable = true;

    zsh.enable = true;

    steam.enable = true;
    gamemode.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    file-roller.enable = true;
  };

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
    ];

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox}";
      EDITOR = "vim";

      NIXOS_OZONE_WL = "1";
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
      trusted-users = [ "root" "supa" ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      pkgs-wayland.overlay

      (self: super: {
        technorino = super.chatterino2.overrideAttrs
          (oldAttrs: {
            nativeBuildInputs = with super; [ cmake pkg-config ];
            buildInputs = with super; [ qt6.wrapQtAppsHook qt6.qtbase qt6.qtsvg qt6.qtimageformats qt6.qttools qt6.qt5compat boost openssl ];
            cmakeFlags = [ "-DBUILD_WITH_QT6=ON" "-DBUILD_WITH_QTKEYCHAIN=OFF" ];
            src = super.chatterino2.src.override {
              owner = "2547techno";
              repo = "technorino";
              rev = "54621083eb57d3e4565c1aa6e9ed6f19a5610dc7";
              hash = "sha256-7ulRZPV/WVRH0HFm+V6rd67nviV+brhmtApw4jA/ZvE=";
            };
          });
      })
    ];
  };

  system.stateVersion = "24.05"; # do not change
}
