{
  config,
  pkgs,
  lib,
  ...
}:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";

    gtk = {
      enable = true;
      icon.enable = true;
    };

    sway.enable = true;
    mpv.enable = true;
  };

  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  home = {
    username = "supa";
    homeDirectory = "/home/supa";

    stateVersion = "23.11"; # do not change

    packages = [
      # pkgs.hello
    ];

    pointerCursor = {
      name = "BreezeX-RosePineDawn-Linux";
      package = pkgs.rose-pine-cursor;
      size = 18;
      x11.enable = true;
      gtk.enable = true;
    };
  };

  # disable home-manager news notification
  news.display = "silent";

  wayland.windowManager.sway = {
    enable = true;

    config = {
      terminal = "foot";
      modifier = "Mod1"; # alt

      startup = [
        { command = "nvidia-settings --load-config-only"; }
        {
          command = ''swayidle timeout 15 "pgrep swaylock && swaymsg \"output * power off\"" resume "swaymsg \"output * power on\""'';
        }
        { command = "wl-paste --primary --watch wl-copy --primary --clear"; }
      ];

      input = {
        "*" = {
          accel_profile = "flat";
        };
        "type:keyboard" = {
          xkb_layout = "us,ro(winkeys)";
          xkb_options = "grp:win_space_toggle";
        };
      };

      output = {
        HDMI-A-1 = {
          mode = "1920x1080@60Hz";
          pos = "0 0";
        };
        DP-1 = {
          mode = "1920x1080@144Hz";
          pos = "1920 0";
          bg = "${./. + "/assets/wall.png"} fill";
        };
      };

      keybindings =
        let
          cfg = config.wayland.windowManager.sway.config;
          modifier = cfg.modifier;
          terminal = cfg.terminal;
        in
        lib.mkOptionDefault {
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 4%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 4%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_SINK@ toggle";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "F9" = "exec grim -g \"$(slurp)\" - | wl-copy --type=image/png";
          "Print" = "exec grim -g \"$(slurp)\" - | wl-copy --type=image/png";
          "${modifier}+d" = "exec ${lib.getExe pkgs.fuzzel}";
          "Control+${modifier}+t" = "exec ${terminal}";
          "Mod4+d" = "workspace 5; workspace 2";
          "Mod4+l" = "exec swaylock -f";

          # move focused workspace between monitors
          "${modifier}+Shift+comma" = "move workspace to output right";
          "${modifier}+Shift+period" = "move workspace to output left";
        };

      focus = {
        followMouse = false;
        wrapping = "no";
        mouseWarping = false;
      };

      workspaceAutoBackAndForth = true;

      workspaceOutputAssign = [
        {
          output = "DP-1";
          workspace = "1";
        }
        {
          output = "DP-1";
          workspace = "2";
        }
        {
          output = "HDMI-A-1";
          workspace = "5";
        }
        {
          output = "HDMI-A-1";
          workspace = "9";
        }
        {
          output = "HDMI-A-1";
          workspace = "10";
        }
      ];

      fonts = {
        names = [ "Monospace" ];
        size = 10.0;
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
          trayOutput = "primary";
          fonts = {
            size = 11.0;
            style = "Bold";
          };
          statusCommand = "${lib.getExe pkgs.i3status-rust} ~/.config/i3status-rust/config-top-patched.toml";
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
        PS1 = "%F{240}[%F{183}%n%f@%F{117}%m %F{169}%~%F{240}]%f$ ";
      };

      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        l = "ls";
        la = "ls -a";
        ll = "ls -l";
        ka = "killall -I -r";
        update = "doas nixos-rebuild switch --flake ~/.dotfiles";
        ip = "ip -color=auto";
        grep = "grep --color=auto";
        vs = "codium";
        s = "ssh";
        v = "vim";
        e = "hx";
        neofetch = "fastfetch";
        sudo = "doas";
      };
      history.size = 5000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      initContent = ''
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
      font = {
        name = "Monospace";
        size = 12;
      };
      extraConfig = ''
        draw_minimal_borders yes
        resize_in_steps no
        background_opacity 0.8
        dynamic_background_opacity yes

        map ctrl+shift+0 set_background_opacity +0.1
        map ctrl+shift+9 set_background_opacity -0.1

        symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
        symbol_map U+f000-U+f2e0 Font Awesome 6 Free
      '';
    };

    foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=12";
        };
        colors = {
          alpha = 0.8;
        };
      };
    };

    swaylock.enable = true;

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
              format = " $icon $mem_used_percents.eng(w:2) ";
              # format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
            }
            {
              block = "temperature";
            }
            {
              block = "bluetooth";
              mac = "80:C3:BA:81:3D:BD";
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
              block = "time";
              format = " $timestamp.datetime(f:'%A, %d %B %H:%M:%S') ";
              interval = 1;
            }
          ];
        };
      };
    };

    fuzzel.enable = true;

    mpv = {
      enable = true;
      bindings = {
        G = "osd-msg-bar seek 100 absolute-percent+exact";

        RIGHT = "seek  5 exact"; # forward
        LEFT = "seek -5 exact"; # backward
        WHEEL_UP = "seek  5 exact"; # forward
        WHEEL_DOWN = "seek -5 exact"; # backward

        UP = "seek  30 exact"; # forward
        DOWN = "seek -30 exact"; # backward

        "Alt+=" = "add video-zoom 0.1";
      };
      config = {
        vo = "gpu-next";
        hwdec = "auto-copy";
        hwdec-codecs = "all";
        profile = "gpu-hq";
        dscale = "catmull_rom";
        #gpu-api="vulkan"; # might cause block artifacts on fast pacing videos (?)
        ao = "pipewire";

        screenshot-format = "png";
        screenshot-directory = "~/Pictures";
        screenshot-tag-colorspace = "no"; # because of gpu-next png tagging bug
        screenshot-high-bit-depth = "no"; # bloat
        screenshot-png-compression = 6;
        screenshot-png-filter = 0;

        keep-open = "yes";
        force-window = "yes";
        osd-bar-w = 40;
        osd-bar-h = 2;
        volume-max = 200;
        cursor-autohide = 100;
        sub-border-size = 2;
        #title="mpv";
      };
      profiles = {
        stream = {
          #vd-lavc-threads=1;
          demuxer-lavf-o-add = "fflags=+nobuffer+fastseek+flush_packets";
          demuxer-lavf-probe-info = "auto";
          demuxer-lavf-analyzeduration = 0.1;
          #demuxer-readahead-secs=30;
          demuxer-max-bytes = "128M";
          demuxer-max-back-bytes = "128M";
          #cache="no";
          gapless-audio = "yes";
          prefetch-playlist = "yes";
          #audio-buffer=0.1;
          #cache-secs=1;
          cache-pause = "no";
          untimed = "yes";
          video-sync = "audio";
          force-seekable = "yes";
          hr-seek = "yes";
          hr-seek-framedrop = "yes";
          interpolation = "no";
          video-latency-hacks = "yes";
          #stream-buffer-size="4k";
        };
      };
    };

    helix = {
      enable = true;
      settings = {
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
        keys.normal = {
          space.space = "file_picker";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
      };
    };
  };

  services = {
    mako = {
      enable = true;
      settings.default-timeout = 5000;
    };

    mpris-proxy.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";

      "applications/x-www-browser" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/chrome" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
      "application/x-extension-htm" = "librewolf.desktop";
      "application/x-extension-html" = "librewolf.desktop";
      "application/x-extension-shtml" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "application/x-extension-xhtml" = "librewolf.desktop";
      "application/x-extension-xht" = "librewolf.desktop";
      "application/pdf" = "librewolf.desktop";

      "text/html" = "codium.desktop";
      "text/plain" = "codium.desktop";
      "application/octet-stream" = "codium.desktop";
      "application/x-zerosize" = "codium.desktop";

      "image/png" = "nsxiv.desktop";
      "image/jpg" = "nsxiv.desktop";
      "image/jpeg" = "nsxiv.desktop";
      "image/gif" = "nsxiv.desktop";
      "image/webp" = "nsxiv.desktop";
      "image/heic" = "nsxiv.desktop";
      "image/apng" = "nsxiv.desktop";
      "image/svg+xml" = "nsxiv.desktop";

      "video/*" = "mpv.desktop";
    };
  };

  xresources.properties = {
    "*background" = "#24273a";
    "*foreground" = "#cad3f5";
    "*cursorColor" = "#f4dbd6";

    # black
    "*color0" = "#494d64";
    "*color8" = "#5b6078";

    # red
    "*color1" = "#ed8796";
    "*color9" = "#ed8796";

    # green
    "*color2" = "#a6da95";
    "*color10" = "#a6da95";

    # yellow
    "*color3" = "#eed49f";
    "*color11" = "#eed49f";

    # blue
    "*color4" = "#8aadf4";
    "*color12" = "#8aadf4";

    # magenta
    "*color5" = "#f5bde6";
    "*color13" = "#f5bde6";

    # cyan
    "*color6" = "#8bd5ca";
    "*color14" = "#8bd5ca";

    # white
    "*color7" = "#b8c0e0";
    "*color15" = "#a5adcb";
  };
}
