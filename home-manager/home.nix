{
  config,
  pkgs,
  userSettings,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./qutebrowser.nix
    ./waybar.nix
    ./gallery-dl.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = userSettings.username;
    homeDirectory = userSettings.homeDirectory;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        ncmpcpp = pkgs.ncmpcpp.override {
          visualizerSupport = true;
        };
        rofi = pkgs.rofi-wayland;
      };
    };

    overlays = [];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      waybar
      dfc
      pyprland
      hyprlock
      hypridle
      hyprpicker
      neomutt
      bemenu
      hydrus
      qutebrowser
      qbittorrent
      ffmpeg
      yt-dlp
      gallery-dl
      sxiv
      zathura
      lazygit
      libcanberra-gtk3
      wl-clipboard
      libsForQt5.kservice
      adwaita-qt
      adwaita-qt6
      lxqt.pavucontrol-qt
      imagemagick
      krita
      gimp
      grim
      slurp
      offlineimap
      libreoffice-qt
      wine
      winetricks
      icoutils
      mpc-cli
      octave
      pinentry-qt
      vesktop
      trash-cli
    ]
    ++ (with kdePackages; [
      dolphin
      oxygen-icons
      ocean-sound-theme
      oxygen-sounds
      ffmpegthumbs
      kdegraphics-thumbnailers
      kimageformats
      kservice
      knotifications
    ]);

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-material-color
    ];
  };

  xdg.configFile."lf/icons".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
    hash = "sha256-c0orDQO4hedh+xaNrovC0geh5iq2K+e+PZIL5abxnIk=";
  };

  programs = {
    lf = {
      enable = true;
      commands = let
        paste = pkgs.writeShellScript "paste" ''
          #!/bin/sh
          set -- $(cat ~/.local/share/lf/files)
          mode="$1"
          shift
          case "$mode" in
              copy)
                  rsync -av --ignore-existing --progress -- "$@" . |
                  stdbuf -i0 -o0 -e0 tr '\r' '\n' |
                  while IFS= read -r line; do
                      lf -remote "send $id echo $line"
                  done
                  ;;
              move) mv -n -- "$@" .;;
          esac
          rm ~/.local/share/lf/files
          lf -remote "send clear"
        '';
      in {
        editor-open = ''$$EDITOR $f'';
        paste = ''&{{${paste}}}'';
        trash = ''%trash-put $fx'';
      };
      settings = {
        preview = false;
        drawbox = true;
        icons = true;
        ignorecase = true;
        sixel = true;
        ratios = [1 5];
		tabstop = 4;
      };
      keybindings = let
        toggle_preview = pkgs.writeShellScript "toggle_preview" ''
          #!/bin/sh
             if [ "$lf_preview" = "true" ]; then
                 lf -remote "send $id :set preview false; set ratios 1:5"
             else
                 lf -remote "send $id :set preview true; set ratios 1:2:3"
             fi
        '';
        bulk-rename = pkgs.writeShellScript "bulk-rename" ''
          #!/bin/sh
          old="$(mktemp)"
          new="$(mktemp)"
          if [ -n "$fs" ]; then
              fs="$(basename -a $fs)"
          else
              fs="$(ls)"
          fi
          printf '%s\n' "$fs" >"$old"
          printf '%s\n' "$fs" >"$new"
          $EDITOR "$new"
          [ "$(wc -l < "$new")" -ne "$(wc -l < "$old")" ] && exit
          paste "$old" "$new" | while IFS= read -r names; do
              src="$(printf '%s' "$names" | cut -f1)"
              dst="$(printf '%s' "$names" | cut -f2)"
              if [ "$src" = "$dst" ] || [ -e "$dst" ]; then
                  continue
              fi
              mv -- "$src" "$dst"
          done
          rm -- "$old" "$new"
          lf -remote "send $id unselect"

        '';
      in {
        "<enter>" = "open";
        "zp" = ''''$${toggle_preview}'';
        "DD" = "trash";
        "R" = ''''$${bulk-rename}'';
      };
      previewer = {
        keybinding = "i";
        source = pkgs.writeShellScript "pv.sh" ''
          #!/bin/sh
          case $1 in
             *.tar*) tar tf "$1";;
             *.7z|*.zip|*.rar) 7z l "$1";;
             *.pdf) pdftotext "$1" -;;
             *.png|*.jpg|*.webp|*.gif) img2sixel -S -w $(($2 * 5)) -h auto $1;;
             *) highlight -O ansi "$1" || cat "$1";;
          esac
        '';
      };
    };

    rofi = {
      enable = true;
      font = "Unifont";
      location = "center";
      pass = {
        enable = true;
        package = pkgs.rofi-pass-wayland;
      };
    };

    fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.js";
        logo = {
          type = "raw";
          source = "~/.config/fastfetch/sixel";
          padding = {
            top = 0;
            left = 1;
          };
          width = 40;
          height = 20;
        };
        modules = [
          "os"
          "separator"
          "host"
          "kernel"
          "packages"
          "shell"
          "de"
          "wm"
          "terminal"
          {
            type = "cpu";
            format = "{1} {2}";
          }
          "memory"
          "break"
          "break"
          "break"
          "colors"
          "break"
          "separator"
          {
            type = "title";
            format = "Art by @raika9";
          }
        ];
      };
    };

    git = {
      enable = true;
      userName = userSettings.name;
      userEmail = userSettings.email;
    };

    fish = {
      enable = true;
      shellInit =
        /*
        sh
        */
        ''
          set fish_greeting
          fish_hybrid_key_bindings
          set -xU MANPAGER 'less'
          set -xU MANROFFOPT '-P -c'
          bind -M default \cf lf
          bind -M insert \cf lf

        '';
      shellAliases = {
        vi = "nvim";
      };
      functions = {
        fish_prompt = {
          body =
            /*
            sh
            */
            ''
                set -l last_pipestatus $pipestatus
                set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
                set -l normal (set_color normal)
                set -q fish_color_status
                or set -g fish_color_status red

                # Color the prompt differently when we're root
                set -l color_cwd $fish_color_cwd
                set -l suffix '─▪'
                if functions -q fish_is_root_user; and fish_is_root_user
                  if set -q fish_color_cwd_root
                    set color_cwd $fish_color_cwd_root
                  end
                  set suffix '#'
                end

                # Write pipestatus
                # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
                set -l bold_flag --bold
                set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
                if test $__fish_prompt_status_generation = $status_generation
                  set bold_flag
                end
                set __fish_prompt_status_generation $status_generation
                set -l status_color (set_color $fish_color_status)
                set -l statusb_color (set_color $bold_flag $fish_color_status)
                set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)
              #
              #   echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
              # end

                echo -n -s "$prompt_status $suffix "
            '';
        };
        cheat = {
          body = "curl cheat.sh/$argv[1]";
        };
      };
      plugins = with pkgs.fishPlugins; [
        {
          name = "fzf-fish";
          src = fzf-fish.src;
        }
        {
          name = "pisces";
          src = pisces.src;
        }
        {
          name = "colored-man-pages";
          src = colored-man-pages.src;
        }
      ];
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      escapeTime = 10;
      shell = userSettings.shell;
      extraConfig =
        /*
        sh
        */
        ''
          set-option -sa terminal-features ',foot:RGB'
          set-option -g focus-events on

          bind | split-window -h -c '#{pane_current_path}'
          bind - split-window -v -c '#{pane_current_path}'

          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D

          bind -n M-h select-pane -L
          bind -n M-l select-pane -R
          bind -n M-k select-pane -U
          bind -n M-j select-pane -D

          #Resizing panes:
          bind -r j resize-pane -D 2
          bind -r k resize-pane -U 2
          bind -r h resize-pane -L 2
          bind -r l resize-pane -R 2

          setw -g monitor-activity on
          set -g visual-activity on
          set -g base-index 1

          # set -g status-left-length 85
          set -g status-right-length 90
          set -g status-style bg=default

          set -g status-left ' #S '
          set -g window-status-current-format "#[fg=#3b383e, bg=#a9dc76, bold] #I #[fg=#a9dc76,bg=#3b383e, bold] #W "
          set -g status-right "#[fg=#3b383e, bg=#a9dc76, bold]  #[fg=#a9dc76,bg=#3b383e, bold] #(fish -c 'prompt_pwd $(tmux display-message -p '#{pane_current_path}')')  #[default] "

          bind [ copy-mode
          bind Escape copy-mode
          bind -Tcopy-mode-vi v send -X begin-selection
          bind -Tcopy-mode-vi y send -X copy-pipe 'xclip -in -selection clipboard' \; display-message "Copied to system clipboard"
          bind -Tcopy-mode-vi C-v send -X rectangle-toggle
          bind ] paste-buffer

        '';
    };

    foot = {
      enable = true;
      settings = {
        main = {
          font = "${userSettings.mainFont}:size=12,${userSettings.jpFont}:size=12,NotoColorEmoji:size=11,${userSettings.nerdFont}:size=7";
          pad = "0x5";
          notify = "notify-send -a \${app-id} -i \${app-id} \${title} \${body}";
          notify-focus-inhibit = "yes";
        };
        bell = {
          urgent = "no";
          notify = "no";
          command = "paplay ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/completion-partial.oga";
          command-focused = "yes";
        };
        colors = {
          # alpha=1.0
          background = "2d2a2e";
          foreground = "e3e1e4";

          ## Normal/regular colors (color palette 0-7)
          regular0 = "000000"; # black
          regular1 = "f85e84"; # red
          regular2 = "9ecd6f"; # green
          regular3 = "e5c463"; # yellow
          regular4 = "76cce0"; # blue
          regular5 = "b39df3"; # magenta
          regular6 = "ef9062"; # cyan
          regular7 = "e3e1e4"; # white

          ## Bright colors (color palette 8-15)
          bright0 = "848089"; # bright black
          bright1 = "f85e84"; # bright red
          bright2 = "9ecd6f"; # bright green
          bright3 = "e5c463"; # bright yellow
          bright4 = "76cce0"; # bright blue
          bright5 = "b39df3"; # bright magenta
          bright6 = "ef9062"; # bright cyan
          bright7 = "e3e1e4"; # bright white
        };
      };
    };

    ncmpcpp = {
      enable = true;
      bindings = [
        {
          key = "k";
          command = "scroll_up";
        }
        {
          key = "j";
          command = "scroll_down";
        }
        {
          key = "ctrl-u";
          command = "page_up";
        }
        {
          key = "ctrl-d";
          command = "page_down";
        }
        {
          key = "l";
          command = ["next_column" "slave_screen"];
        }
        {
          key = "h";
          command = ["previous_column" "master_screen "];
        }
        {
          key = "m";
          command = "show_media_library";
        }
        {
          key = "v";
          command = "show_visualizer";
        }
        {
          key = "n";
          command = "next_found_item";
        }
        {
          key = "N";
          command = "previous_found_item";
        }
        {
          key = ".";
          command = "show_lyrics";
        }
      ];
      settings = {
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_output_name = "Visualizer feed";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "||";
        visualizer_color = "159";
        browser_sort_mode = "name";
        browser_sort_format = "{%A - }{%t}|{%f {(%l)}}";
        autocenter_mode = "yes";
        centered_cursor = "yes";
        progressbar_look = "__";
        user_interface = "alternative";
        startup_screen = "visualizer";
        startup_slave_screen = "playlist";
        startup_slave_screen_focus = "yes";
        locked_screen_width_part = "45";
        external_editor = "nvim";
      };
    };

    mpv = {
      enable = true;
      config = {
        geometry = "50%:50%";
        keep-open = true;
        force-window = "immediate";
        osc = true;
        ontop = true;
        vo = "gpu";
        gpu-dumb-mode = true;
        gpu-api = "opengl";
        gpu-context = "wayland";
        alang = "jpn, jp, eng, en";
        slang = "eng, en, enUS";
        dither-depth = "auto";
        hwdec = "auto";
        screenshot-directory = "~/Pictures/Screenshots/mpv";
        screenshot-template = "%f_%P";
        screenshot-format = "jpg";
      };
      bindings = {
        r = "no-osd cycle video-rotate 90";
        R = "no-osd cycle video-rotate -90";
        h = "vf toggle hflip";
      };
      profiles = {
        "extension.webm" = {
          loop-file = "inf";
        };
        "extension.gif" = {
          loop-file = "inf";
        };
      };
      scripts = with pkgs.mpvScripts; [
        mpv-webm
        uosc
        thumbfast
      ];
    };

    bottom = {
      enable = true;
      settings = {
        flags = {
          hide_avg_cpu = true;
          left_legend = true;
          hide_time = true;
        };
        colors = {
          table_header_color = "Gray";
          border_color = "Red";
          highlighted_border_color = "LightBlue";
          selected_bg_color = "LightRed";
        };
        row = [
          {
            ratio = 30;
            child = [{type = "cpu";}];
          }
          {
            ratio = 35;
            child = [
              {
                ratio = 2;
                child = [
                  {type = "disk";}
                  {type = "temp";}
                ];
              }
              {
                ratio = 2;
                type = "mem";
              }
            ];
          }
          {
            ratio = 35;
            child = [
              {type = "net";}
              {
                type = "proc";
                default = true;
              }
            ];
          }
        ];
      };
    };
  };

  services = {
    dunst = {
      enable = true;
      iconTheme = {
        package = pkgs.kdePackages.oxygen-icons;
        name = "oxygen/base";
        size = "32x32";
      };
      settings = {
        global = {
          follow = "mouse";
          geometry = "320x5-15+15";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = "10";
          notification_height = "70";
          seperator_height = "2";
          padding = "40";
          horizontal_padding = "8";
          frame_width = "3";
          frame_color = "#FFFFFF";
          sort = "yes";
          idle_threshold = "120";
          font = "${userSettings.mainFont} 10";
          line_height = "0";
          markup = "full";
          format = ''<b>%s</b>\n%b'';
          alignment = "left";
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = "true";
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = "32";
          corner_radius = "5";
          progress_bar_frame_width = "1";
          progress_bar_height = "5";
          progress_bar_corner_radius = "5";
        };

        urgency_low = {
          background = "#282A36";
          foreground = "#FFFFFF";
          timeout = 10;
        };
        urgency_normal = {
          background = "#282A36";
          foreground = "#FFFFFF";
          timeout = 10;
        };
        urgency_critical = {
          background = "#900000";
          foreground = "#FFFFFF";
          frame_color = "#FF0000";
          timeout = 0;
        };
      };
    };

    mpd = {
      enable = true;
      musicDirectory = builtins.toPath "${userSettings.homeDirectory}/Music";
      dbFile = "~/.config/mpd/database";
      playlistDirectory = builtins.toPath "${userSettings.homeDirectory}/.config/mpd/playlists";
      dataDir = builtins.toPath "${userSettings.homeDirectory}/.config/mpd/state";
      network = {
        port = 6600;
      };
      extraConfig = ''

        audio_output {
          type  "pipewire"
          name  "PipeWire Sound Server"
        }

        audio_output {
          type            "fifo"
          name            "Visualizer feed"
          path            "/tmp/mpd.fifo"
          format          "44100:16:2"
        }

      '';
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "application/vnd.microsoft.portable-executable" = ["wine.desktop"];
      "image/png" = ["sxiv.desktop"];
      "image/jpg" = ["sxiv.desktop"];
      "image/jpeg" = ["sxiv.desktop"];
      "image/webp" = ["sxiv.desktop"];
      "image/gif" = ["mpv.desktop"];
      "video/*" = ["mpv.desktop"];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry-qt}/bin/pinentry-qt

    '';

    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/oni/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = userSettings.shell;
  };

  systemd.user.services = {
    org-notifications = {
      Unit.Description = "Run neovim every minute for org notifications";

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.neovim}/bin/nvim -u NONE --noplugin --headless -c 'lua require(\"partials.org_cron\")'";
      };
      Install.WantedBy = ["default.target"];
    };
  };

  systemd.user.timers = {
    org-notifications = {
      Unit.Description = "Run neovim every minute for org notifications";

      Timer = {
        Unit = "org-notifications.service";
        OnCalendar = "*-*-* *:*:00";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
