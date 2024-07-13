# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, inputs, pkgs, pkgs-stable, callPackage, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services.nix
    ];

  fileSystems = {
    "/".options = [ "compress=zstd" "relatime" "commit=60" ];
    "/home".options = [ "compress=zstd" "relatime" "lazytime" "commit=60" ];
    "/nix".options = [ "compress=zstd" "noatime" "commit=60" ];
  };

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

  networking = {
    hostName = "Kappa";
    # nameservers = [
    #   "1.1.1.1"
    #   "1.0.0.1"
    #   "2606:4700:4700::1111"
    #   "2606:4700:4700::1001"
    # ];
    # networkmanager.enable = true;
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

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  nix = {
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

    buildMachines = [
      {
        hostName = "cino";
        sshUser = "supa";
        sshKey = "/home/supa/.ssh/id_ed25519";
        system = "x86_64-linux";
        maxJobs = 3;
      }
    ];
    distributedBuilds = true;
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      # chatterino2 = super.chatterino2.overrideAttrs # chatterino2 nightly
      #   (oldAttrs: {
      #     nativeBuildInputs = with super; [ cmake pkg-config ];
      #     buildInputs = with super; [ qt6.wrapQtAppsHook qt6.qtbase qt6.qtsvg qt6.qtimageformats qt6.qttools qt6.qt5compat boost openssl ];
      #     cmakeFlags = [ "-DBUILD_WITH_QT6=ON" "-DBUILD_WITH_QTKEYCHAIN=OFF" ];
      #     src = super.chatterino2.src.override {
      #       rev = "nightly-build";
      #       sha256 = "sha256-kE8/xWmbqvKX14PBcUDjbs6lJGzu1zezEKdDvSJGXVo=";
      #     };
      #   });
      technorino = super.chatterino2.overrideAttrs
        (oldAttrs: {
          nativeBuildInputs = with super; [ cmake pkg-config ];
          buildInputs = with super; [ qt6.wrapQtAppsHook qt6.qtbase qt6.qtsvg qt6.qtimageformats qt6.qttools qt6.qt5compat boost openssl ];
          cmakeFlags = [ "-DBUILD_WITH_QT6=ON" "-DBUILD_WITH_QTKEYCHAIN=OFF" ];
          src = super.chatterino2.src.override {
            owner = "2547techno";
            repo = "technorino";
            rev = "nightly-build";
            sha256 = "sha256-MaK66P6mOAx0FkVEKRy3UwFz6J92zlq+V/YO/HQ8zco==";
          };
        });
    })
  ];

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

  qt = {
    enable = true;
    platformTheme = "qt5ct";
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

      desktopManager = {
        xterm.enable = false;
      };

      displayManager.lightdm = {
        autoLogin.timeout = 0;
        greeter.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3lock
          xss-lock
        ];
      };

      xkb = {
        layout = "us,ro";
        variant = ",winkeys";
        options = "grp:win_space_toggle";
      };
    };

    libinput.mouse.accelProfile = "flat";

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "supa";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    autorandr = {
      enable = true;
      profiles = {
        "default" = {
          # Use `autorandr --fingerprint` on your setup
          fingerprint = {
            DP-2 = "00ffffffffffff0005e390255a7f00002c1d0104a5361e783b9051a75553a028135054bfef00d1c081803168317c4568457c6168617c023a801871382d40582c4500202f2100001efc7e80887038124018203500202f2100001e000000fc003235393047340a202020202020000000fd001e92a0a021010a20202020202001aa02031ef14b0103051404131f12021190230907078301000065030c001000866f80a07038404030203500202f2100001efe5b80a07038354030203500202f2100001e011d007251d01e206e285500202f2100001eab22a0a050841a3030203600202f2100001a7c2e90a0601a1e4030203600202f2100001a00000000000000f9";
            HDMI-0 = "00ffffffffffff00410ccfc0994f0000071d010380301b782a3935a25952a1270c5054bd4b00d1c09500950fb30081c0818001010101023a801871382d40582c4500dd0c1100001e000000ff005a563031393037303230333737000000fc0050484c2032323356350a202020000000fd00384c1e5311000a20202020202001a7020322f14f010203050607101112131415161f04230917078301000065030c001000023a801871382d40582c4500dd0c1100001e8c0ad08a20e02d10103e9600dd0c11000018011d007251d01e206e285500dd0c1100001e8c0ad090204031200c405500dd0c110000180000000000000000000000000000000000000000004d";
          };

          config = {
            DP-2 = {
              enable = true;
              crtc = 0;
              primary = true;
              position = "1920x0";
              mode = "1920x1080";
              rate = "144.00";
            };
            HDMI-0 = {
              enable = true;
              crtc = 1;
              primary = false;
              position = "0x0";
              mode = "1920x1080";
              rate = "60.00";
            };
          };
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

    picom.enable = true;

    gvfs.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users = {
      supa = {
        isNormalUser = true;
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

          # Utils/Misc
          kitty # Terminal
          fastfetch
          yt-dlp
          dunst # Notification daemon
          rofi # App launcher
          pavucontrol # Volume control
          arandr # xrandr GUI
          nitrogen # Wallpaper picker
          keepassxc # Password manager
          flameshot # Screenshots
          headsetcontrol # Used for disabling shitty RGB
          songrec # Shazam song recognition
          font-manager
          scrcpy
          filezilla
          curlie
          gnupg
          kleopatra
          session-desktop
          bottles
          heroic
          birdtray

          # Code
          vscodium
          nixpkgs-fmt # Used for nix formatting in vscode
          github-desktop
          helix
          bruno
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
      qt5ct
      adwaita-qt
      adw-gtk3
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
      networkmanagerapplet
      config.boot.kernelPackages.cpupower
      busybox
      libclang

      (inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
        inherit pkgs;
        module = import ./nixvim;
        # colorschemes.gruvbox.enable = true;
      })
    ];
  };

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

  programs = {
    firefox.enable = true;

    zsh.enable = true;
    dconf.enable = true;

    steam.enable = true;
    gamemode.enable = true;

    gnupg.agent.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    xss-lock = {
      enable = true;
      lockerCommand = "${lib.getExe pkgs.i3lock} --color 000000 --nofork";
    };
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "supa" ];

  system.stateVersion = "23.11"; # Do not change
}
