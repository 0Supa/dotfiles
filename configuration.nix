# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, callPackage, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services.nix
    ];

  fileSystems = {
    "/".options = [ "compress=zstd" "relatime" ];
    "/home".options = [ "compress=zstd:4" "relatime" "lazytime" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
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
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;

      substituters = [
        "https://cache.nixos.org"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      noto-fonts-color-emoji
      noto-fonts-emoji
      font-awesome
      iosevka
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Extended" ];
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
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  services = {
    xserver = {
      enable = true;

      videoDrivers = [ "nvidia" ];

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";
        autoLogin.enable = true;
        autoLogin.user = "supa";
        lightdm.autoLogin.timeout = 0;
        lightdm.greeter.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3lock
          xss-lock
        ];
      };

      libinput.mouse.accelProfile = "flat";
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
          # use `autorandr --fingerprint` on your setup
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
        # send a message to turn off headphones rgb every minute
        "* * * * *  root  ${lib.getExe pkgs.headsetcontrol} -l 0"
      ];
    };

    picom.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users = {
      supa = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [
          chatterino2
          polybar
          flameshot
          pcmanfm
          rofi
          vscodium
          nixpkgs-fmt
          spotify
          picom
          pkg-config
          obs-studio
          gh
          github-desktop
          arandr
          electrum
          chromium
          nitrogen
          nsxiv
          prismlauncher
          headsetcontrol
        ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      vim
      wget
      git
      dunst
      firefox
      neofetch
      kitty
      pavucontrol
      htop
      bottom
      keepassxc
      qt5ct
      adwaita-qt
      adw-gtk3
      go
      nodejs
      zbar
      yt-dlp
      playerctl
      autorandr
      scrot
      mpv
      psmisc
    ];
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;

    steam.enable = true;

    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.i3lock}/bin/i3lock --color 000000 --nofork";
    };
  };

  system.stateVersion = "23.11"; # do not change
}
