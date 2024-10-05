{ config, pkgs, lib, ... }:

{
  catppuccin.flavor = "macchiato";
  catppuccin.enable = true;

  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
      icon.enable = true;
    };
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
    catppuccin.enable = true;

    config = {
      terminal = "kitty";
      modifier = "Mod1"; # alt

      startup = [
        { command = "nvidia-settings --load-config-only"; }
        { command = ''swayidle timeout 15 "pgrep -x swaylock && swaymsg \"output * dpms off\"" resume "swaymsg \"output * dpms on\""''; }
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
        DP-2 = {
          mode = "1920x1080@144Hz";
          pos = "1920 0";
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
          # "F9" = "exec grim -g \"$(slurp)\" - | wl-copy --type=image/png";
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
        { output = "DP-2"; workspace = "1"; }
        { output = "DP-2"; workspace = "2"; }
        { output = "HDMI-A-1"; workspace = "5"; }
        { output = "HDMI-A-1"; workspace = "10"; }
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
        update = "doas nixos-rebuild switch --flake ~/.dotfiles";
        updatehm = "rm /home/supa/.config/mimeapps.list; home-manager switch --flake ~/.dotfiles";
        ip = "ip -color=auto";
        grep = "grep --color=auto";
        vs = "codium";
        s = "kitten ssh";
        v = "vim";
        neofetch = "fastfetch";
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
      font = {
        name = "Monospace";
        size = 12;
      };
      extraConfig = ''
        draw_minimal_borders yes
        resize_in_steps no
        background_opacity 0.8

        symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
        symbol_map U+f000-U+f2e0 Font Awesome 6 Free
      '';
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
        vo = "gpu";
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
          esc = [ "collapse_selection" "keep_primary_selection" ];
        };
      };
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
  };

  services = {
    mako = {
      enable = true;
      defaultTimeout = 5000;
    };
  };

  xresources.properties = {
    "*.background" = "#000000";
    "*.foreground" = "#00C0FF";
  };
}
