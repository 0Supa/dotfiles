{ config, pkgs, lib, ... }:

{
  home = {
    username = "supa";
    homeDirectory = "/home/supa";

    stateVersion = "23.11"; # do not change

    packages = [
      # pkgs.hello
    ];

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox}";
      DISPLAY = ":0";
      EDITOR = "nvim";
    };

    pointerCursor = {
      name = "macOS-BigSur";
      package = pkgs.apple-cursor;
      size = 16;
      x11.enable = true;
      gtk.enable = true;
    };

    file = {
      ".local/share/chatterino/Themes/mocha-mauve.json".source = ./config/chatterino/mocha-mauve.json;
      ".local/share/rofi/themes/catppuccin-mocha.rasi".source = ./config/rofi/catppuccin-mocha.rasi;
      ".config/rofi/config.rasi".source = ./config/rofi/config.rasi;
    };
  };

  # disable home-manager news notification
  news.display = "silent";

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "emacs";

      localVariables = {
        PS1 = "%F{240}[%F{120}%n%f@%F{cyan}%m %F{139}%~%F{240}]%f$ ";
      };

      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        l = "ls";
        la = "ls -a";
        ll = "ls -l";
        ka = "killall -I";
        lock = "xset dpms force off";
        dink = "dunstctl history-pop";
        update = "sudo nixos-rebuild switch --flake ~/.dotfiles";
        updatehm = "home-manager switch --flake ~/.dotfiles";
        ip = "ip -color=auto";
        grep = "grep --color=auto";
        vs = "codium";
        s = "kitten ssh";
        v = "nvim";
      };
      history.size = 5000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      initExtra = ''
        zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}"
      
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^H" backward-kill-word
        bindkey "5~" kill-word
        bindkey "^[[3~" delete-char
      '';
    };

    kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      font = {
        name = "Iosevka Term Extended";
        size = 12;
      };
      extraConfig = ''
        draw_minimal_borders yes
        resize_in_steps yes
        background_opacity 0.8

        symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
        symbol_map U+f000-U+f2e0 Font Awesome 6 Free
      '';
    };

    i3status-rust = {
      enable = true;
      bars = {
        top = {
          settings = {
            theme = {
              theme = "ctp-mocha";
              overrides = {
                alternating_tint_bg = "#181825";
              };
            };
          };
          icons = "awesome5";
          blocks = [
            {
              block = "cpu";
            }
            {
              alert = 10.0;
              block = "disk_space";
              format = " $icon root: $available.eng(w:2) ";
              info_type = "available";
              interval = 20;
              path = "/";
              warning = 20.0;
            }
            {
              block = "memory";
              format = " $icon $mem_total_used_percents.eng(w:2) ";
              format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
            }
            {
              block = "temperature";
            }
            {
              block = "sound";
              click = [
                {
                  button = "left";
                  cmd = "pavucontrol";
                }
              ];
            }
            {
              block = "notify";
            }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%A, %d %B %H:%M:%S') ";
              interval = 1;
            }
          ];
        };
      };
    };
  };

  services = {
    dunst = {
      enable = true;
      configFile = ./config/dunst/dunstrc;
    };

    picom = {
      enable = true;
      settings = {
        round-borders = 1;
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;

    extraConfig = (builtins.readFile ./config/i3/catppuccin-mocha) + ''
      for_window [class="."] border pixel 1
      for_window [class="."] title_window_icon yes
    '';

    config = {
      terminal = "kitty";
      modifier = "Mod1"; # alt

      startup = [
        { command = "${lib.getExe pkgs.autorandr} default"; }
        { command = "nvidia-settings --load-config-only"; }
        { command = "${lib.getExe' pkgs.keepassxc "keepassxc"}"; }
      ];

      keybindings =
        let
          cfg = config.xsession.windowManager.i3.config;
          modifier = cfg.modifier;
          terminal = cfg.terminal;
        in
        lib.mkOptionDefault {
          "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ 4%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ 4%-";
          "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_SINK@ toggle";
          "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioPause" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioNext" = "exec --no-startup-id playerctl next";
          "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
          "F9" = "exec --no-startup-id flameshot gui";
          "Print" = "exec --no-startup-id flameshot gui";
          "${modifier}+d" = "exec --no-startup-id rofi -show drun";
          "${modifier}+Tab" = "exec --no-startup-id rofi -show window";
          "Control+${modifier}+t" = "exec --no-startup-id ${terminal}";
          "Mod4+d" = "workspace number 5; workspace number 2";

          # move focused workspace between monitors
          "${modifier}+Shift+greater" = "move workspace to output right";
          "${modifier}+Shift+less" = "move workspace to output left";
        };

      focus = {
        followMouse = false;
        wrapping = "no";
      };

      workspaceAutoBackAndForth = true;

      workspaceOutputAssign = [
        { output = "DP-2"; workspace = "1"; }
        { output = "DP-2"; workspace = "2"; }
        { output = "HDMI-0"; workspace = "5"; }
        { output = "HDMI-0"; workspace = "10"; }
      ];

      fonts = {
        names = [ "Iosevka" ];
        size = 9.5;
      };

      colors = {
        focused = {
          text = "$text";
          background = "$base";
          indicator = "$rosewater";
          border = "$mauve";
          childBorder = "$mauve";
        };
        focusedInactive = {
          text = "$overlay0";
          background = "$base";
          indicator = "$rosewater";
          border = "$overlay0";
          childBorder = "$overlay0";
        };
        unfocused = {
          text = "$overlay0";
          background = "$base";
          indicator = "$rosewater";
          border = "$overlay0";
          childBorder = "$overlay0";
        };
        urgent = {
          text = "$peach";
          background = "$base";
          indicator = "$overlay0";
          border = "$peach";
          childBorder = "$peach";
        };
        placeholder = {
          text = "$overlay0";
          background = "$base";
          indicator = "$overlay0";
          border = "$overlay0";
          childBorder = "$overlay0";
        };
      };

      bars = [
        {
          position = "top";
          fonts = {
            size = 10.0;
            style = "Bold";
          };
          statusCommand = "${lib.getExe pkgs.i3status-rust} ~/.config/i3status-rust/config-top.toml";
          colors = {
            background = "$base";
            statusline = "$text";
            focusedStatusline = "$text";
            focusedWorkspace = {
              background = "$surface1";
              border = "$base";
              text = "$mauve";
            };
            activeWorkspace = {
              background = "$surface1";
              border = "$base";
              text = "$blue";
            };
            inactiveWorkspace = {
              background = "$base";
              border = "$base";
              text = "$surface1";
            };
            urgentWorkspace = {
              background = "$peach";
              border = "$base";
              text = "$surface1";
            };
            bindingMode = {
              background = "$base";
              border = "$base";
              text = "$surface1";
            };
          };
        }
      ];
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Catppuccin-Mocha-Compact-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };
  };

  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";

      "image/png" = "nsxiv.desktop";
      "image/jpg" = "nsxiv.desktop";
      "image/jpeg" = "nsxiv.desktop";
      "image/gif" = "nsxiv.desktop";
      "image/webp" = "nsxiv.desktop";
      "image/heic" = "nsxiv.desktop";
      "image/apng" = "nsxiv.desktop";

      "inode/directory" = "pcmanfm.desktop";
    };
  };

  # TODO proper theming
  xresources.properties = {
    "*.background" = "#000000";
    "*.foreground" = "#00C0FF";
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style = {
      name = "qt5ct-style";
    };
  };
}
