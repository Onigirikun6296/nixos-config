{
  config,
  pkgs,
  userSettings,
  lib,
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

    overlays = [
      (final: prev: {
        swayimg = prev.swayimg.overrideAttrs (prev: rec {
          version = "2.5";
          src = pkgs.fetchFromGitHub {
            owner = "artemsen";
            repo = "swayimg";
            rev = "v${version}";
            hash = "sha256-wr0XNcWHcmxj8CW6faq4876q8ADRpQuX5PCVX1l3IZ8=";
          };
          patches = [./patches/swayimg.patch];
        });
      })
    ];
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
      nil
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
      swayimg
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

  programs = {
    yazi = {
      enable = true;
      initLua =
        /*
        lua
        */
        ''
          require("full-border"):setup()
          require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
          require("session"):setup {
          	sync_yanked = true,
          }

          function Status:name()
          	local h = cx.active.current.hovered
          	if not h then
          		return ui.Span("")
          	end

          	local linked = ""
          	if h.link_to ~= nil then
          		linked = " -> " .. tostring(h.link_to)
          	end
          	return ui.Span(" " .. h.name .. linked)
          end

        '';
      keymap = {
        manager = {
          prepend_keymap =
            [
              {
                run = "plugin --sync hide-preview";
                on = ["z" "p"];
              }
              {
                run = "hidden toggle";
                on = ["z" "a"];
              }
              {
                run = "shell '$SHELL' --block --confirm";
                on = ["w"];
              }
              {
                run = "tasks_show";
                desc = "Show the tasks manager";
                on = ["t"];
              }
              {
                run = "plugin --sync smart-enter";
                desc = "Enter the child directory, or open the file";
                on = ["l"];
              }
              {
                run = "plugin --sync smart-enter";
                desc = "Enter the child directory, or open the file";
                on = ["<Enter>"];
              }
              {
                run = ["yank" ''shell --confirm 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' ''];
                on = ["y"];
              }
            ]
            ++ (
              builtins.concatLists (builtins.genList (
                  x: let
                    idx = builtins.toString x;
                  in [
                    {
                      run = "plugin relative-motions --args=${idx}";
                      on = ["${idx}"];
                    }
                  ]
                )
                10)
            );
        };
      };

      plugins = let
        plugin-src = pkgs.fetchgit {
          url = "https://github.com/yazi-rs/plugins/";
          hash = "sha256-iiHkU5DYfDkcBA/XTzTYBuHbdM58iZQt8lEMzagnwcM=";
        };
        smart-enter =
          pkgs.writeTextDir "smart-enter.yazi/init.lua"
          /*
          lua
          */
          ''
            return {
            	entry = function()
            		local h = cx.active.current.hovered
            		ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
            	end,
            }
          '';
      in {
        hide-preview = "${plugin-src}/hide-preview.yazi";
        full-border = "${plugin-src}/full-border.yazi";
        relative-motions = pkgs.fetchgit {
          url = "https://github.com/dedukun/relative-motions.yazi";
          hash = "sha256-S1kdCFPMs1xpjTSBfU49hucPjgtP7J+WcgTH8hijYNU=";
        };
        smart-enter = "${smart-enter}/smart-enter.yazi";
      };
      settings = {
        manager = {
          ratio = [1 2 3];
          show_symlink = false;
        };
        preview = {
          tab_size = 4;
        };
      };
      theme = {
        status = {
          separator_open = " ";
          separator_close = " ";
        };
      };
    };

    rofi = {
      enable = true;
      font = "Unifont 12";
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
        display = {
          separator = " ";
          color = {
            separator = "white";
          };
        };
        modules = [
          {
            type = "custom";
            format = "{#1}{#keys}{#39}╭───────────────System Information────────────────╮";
          }
          {
            type = "os";
            key = "{#33}   os       ";
            format = "{2} {11}";
          }
          {
            type = "host";
            key = "{#33}  󰇄 host     ";
          }
          {
            type = "kernel";
            key = "{#31}   kernel   ";
          }
          {
            type = "packages";
            key = "{#33}  󰟾 packages ";
          }
          {
            type = "shell";
            key = "{#36}   shell    ";
          }
          {
            type = "de";
            key = "{#34}  󰇄 desktop  ";
          }
          {
            type = "wm";
            key = "{#34}   wm       ";
          }
          {
            type = "terminal";
            key = "{#35}   term     ";
          }
          {
            type = "cpu";
            key = "{#35}  󰍛 cpu      ";
            format = "{1}";
          }
          {
            type = "memory";
            key = "{#32}   memory   ";
            format = "";
          }
          {
            type = "colors";
            key = "{#39}   colors   ";
            symbol = "circle";
            format = "";
          }
          {
            type = "custom";
            format = "{#1}{#keys}{#39}╰─────────────────────────────────────────────────╯";
          }
          {
            type = "break";
            format = "";
          }
          {
            type = "break";
            format = "";
          }
          {
            type = "break";
            format = "";
          }
          {
            type = "break";
            format = "";
          }
          {
            type = "break";
            format = "";
          }
          {
            type = "custom";
            format = "{#1}{#keys}{#39}                                     Art by @raika9";
          }
        ];
      };
    };

    git = {
      enable = true;
      userName = userSettings.name;
      userEmail = userSettings.email;
    };

    bash.enable = true;

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
          bind -M default \cf yazi
          bind -M insert \cf yazi

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
      extraConfig = let
        despell = pkgs.rustPlatform.buildRustPackage {
          pname = "despell";
          version = "1.0.1";
          src = pkgs.fetchFromGitHub {
            owner = "bensadeh";
            repo = "despell";
            rev = "55470ff1290f2d67b879b6a666bbbfa3e46f1853";
            hash = "sha256-hivn/jFPAXiak87KyWOZS+1jDDgtekBpX4YVg7tict0=";
          };
          cargoHash = "sha256-ZuUawa774AkP3Ewg8dFYMuATamlhE71y/P6DsyZLpAY=";
        };
      in
        /*
        sh
        */
        ''
          set-option -g focus-events on
          set -g default-terminal 'tmux-256color'
          set-option -sa terminal-features ',xterm-256color:RGB'

          set -g allow-passthrough on
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM

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
          set -g window-status-current-format "#[fg=#3b383e, bg=#a9dc76, bold] #I #[fg=#a9dc76,bg=#3b383e, bold] #(${despell}/bin/despell #W) #W "
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
          font = "${userSettings.mainFont}:size=12,${builtins.replaceStrings ["[GNU ]"] [""] userSettings.jpFont}:size=12,NotoColorEmoji:size=11,${userSettings.nerdFont}:size=9";
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
        external_editor = "$EDITOR";
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
          indicate_hidden = "yes";
          shrink = "no";
          offset = "15x15";
          padding = "20";
          gap_size = "10";
          frame_width = "1";
          frame_color = "#FFFFFF";
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
          progress_bar_frame_width = "1";
          progress_bar_height = "5";
          progress_bar_max_width = "200";
          progress_bar_corner_radius = "5";
          sort = "update";
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
      musicDirectory = /. + "${userSettings.homeDirectory}/Music";
      dbFile = "~/.config/mpd/database";
      playlistDirectory = /. + "${userSettings.homeDirectory}/.config/mpd/playlists";
      dataDir = /. + "${userSettings.homeDirectory}/.config/mpd/state";
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
      "image/png" = ["swayimg.desktop"];
      "image/jpg" = ["swayimg.desktop"];
      "image/jpeg" = ["swayimg.desktop"];
      "image/webp" = ["swayimg.desktop"];
      "image/gif" = ["swayimg.desktop"];
      "video/*" = ["mpv.desktop"];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry-qt}/bin/pinentry-qt

    '';

    ".config/swayimg/config".text = lib.generators.toINI {} {
      general = {
        scale = "optimal";
        fullscreen = "no";
        antialiasing = "no";
        fixed = "yes";
        transparency = "#00000000";
        position = "parent";
        size = "parent";
        background = "#00000000";
        slideshow = "no";
        slideshow_time = 3;
        gallery = "no";
      };
      gallery = {
        size = 150;
        antialiasing = "no";
        window = "#00000000";
        background = "#202020";
        select = "#404040";
      };
      list = {
        order = "alpha";
        loop = "yes";
        recursive = "no";
        all = "yes";
        cache = 1;
        preload = 1;
      };
      font = {
        name = "${userSettings.jpFont}";
        size = 12;
        color = "#cccccc";
        shadow = "#000000a0";
      };
      info = {
        mode = "brief";
        timeout = 0;
        "full.topleft" = "name,format,filesize,imagesize,exif";
        "full.topright" = "index";
        "full.bottomleft" = "scale,frame";
        "full.bottomright" = "status";
        "brief.topleft" = "index";
        "brief.topright" = "none";
        "brief.bottomleft" = "none";
        "brief.bottomright" = "status";
      };
      keys = {
        F1 = "help";
        Home = "first_file";
        End = "last_file";
        p = "prev_file";
        n = "next_file";
        Space = "next_file";
        "Shift+d" = "prev_dir";
        d = "next_dir";
        "Shift+o" = "prev_frame";
        o = "next_frame";
        c = "skip_file";
        "Shift+s" = "slideshow";
        s = "animation";
        f = "fullscreen";
        Return = "mode";
        Left = "step_left 10";
        Right = "step_right 10";
        Up = "step_up 10";
        Down = "step_down 10";
        h = "step_left 10";
        l = "step_right 10";
        k = "step_up 10";
        j = "step_down 10";
        Equal = "zoom real";
        "Shift+Plus" = "zoom +10";
        Minus = "zoom -10";
        w = "zoom width";
        "Shift+w" = "zoom height";
        z = "zoom fit";
        "Shift+z" = "zoom fill";
        "0" = "zoom real";
        Backspace = "zoom optimal";
        "Shift+less" = "rotate_left";
        "Shift+greater" = "rotate_right";
        m = "flip_vertical";
        "Shift+m" = "flip_horizontal";
        a = "antialiasing";
        r = "reload";
        i = "info";
        e = "exec echo \"Image: %\"";
        Escape = "exit";
        q = "exit";
      };
      mouse = {
        ScrollLeft = "step_right 5";
        ScrollRight = "step_left 5";
        ScrollUp = "step_up 5";
        ScrollDown = "step_down 5";
        "Ctrl+ScrollUp" = "zoom +10";
        "Ctrl+ScrollDown" = "zoom -10";
        "Shift+ScrollUp" = "prev_file";
        "Shift+ScrollDown" = "next_file";
        "Alt+ScrollUp" = "prev_frame";
        "Alt+ScrollDown" = "next_frame";
      };
    };

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
    EDITOR = "${pkgs.neovim}/bin/nvim";
    SHELL = userSettings.shell;
    TERMINAL = "${userSettings.term}";
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
