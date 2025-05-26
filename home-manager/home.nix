{
  config,
  pkgs,
  pkgs-stable,
  userSettings,
  lib,
  self,
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
    inherit (userSettings) username;
    inherit (userSettings) homeDirectory;
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.overlays = [
    (final: prev: {
      weechat = prev.weechat.override {
        configure = {availablePlugins, ...}: {
          scripts = with prev.weechatScripts; [
            weechat-notify-send
          ];
        };
      };
     })
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (with pkgs; [
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
      weechat
      rsshub
      rmpc
      fluent-reader
      libnotify
      nil
      waybar
      dfc
      hyprland-qtutils
      hyprlock
      hypridle
      hyprpicker
      hyprland-autoname-workspaces
      neomutt
      bemenu
      hydrus
      qbittorrent
      ffmpeg
      yt-dlp
      gallery-dl
      zathura
      lazygit
      libcanberra-gtk3
      wl-clipboard
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
      (vesktop.override {
        electron = pkgs-stable.electron;
      })
      swayimg
      socat
      comma
      chafa
      lxqt.pavucontrol-qt
      libsForQt5.kservice
      libsForQt5.qt5ct
      chromium
    ])
    ++ (with pkgs-stable; [
      pyprland
    ])
    ++ (with pkgs.kdePackages; [
      dolphin
      qtbase
      qtwayland
      oxygen-icons
      breeze
      breeze-icons
      ocean-sound-theme
      oxygen-sounds
      ffmpegthumbs
      kdegraphics-thumbnailers
      kimageformats
      kservice
      knotifications
      kio-fuse
      kio-extras
      qt6ct
      qtsvg
      systemsettings
      qtstyleplugin-kvantum
      qtimageformats
    ]);

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [
      pkgs-stable.fcitx5-mozc
      pkgs.fcitx5-material-color
    ];
  };

  programs = {
    nix-index.enable = true;
    obs-studio = {
      enable = true;
    };

    yazi = {
      enable = true;
      initLua =
        ""
        +
        /*
        lua
        */
        ''
          require("full-border"):setup({
          	type = ui.Border.PLAIN,
          })
          require("relative-motions"):setup({ show_numbers = "relative_absolute", show_motion = true })
          require("session"):setup {
          	sync_yanked = true,
          }
          Status:children_add(function(self)
          	local h = self._current.hovered
          	if h and h.link_to then
          		return " -> " .. tostring(h.link_to)
          	else
          		return ""
          	end
          end, 3300, Status.LEFT)

          Status:children_add(function()
          	local h = cx.active.current.hovered
          	if h == nil or ya.target_family() ~= "unix" then
          		return ""
          	end

          	return ui.Line {
          		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
          		":",
          		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
          		" ",
          	}
          end, 500, Status.RIGHT)

          Header:children_add(function()
          	if ya.target_family() ~= "unix" then
          		return ""
          	end
          	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
          end, 500, Header.LEFT)

        '';

      keymap = {
        manager = {
          prepend_keymap =
            [
              {
                run = "plugin toggle-pane min-preview";
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
                run = "close";
                desc = "Cancel input";
                on = ["<Esc>"];
              }
              {
                run = "plugin jump-to-char";
                desc = "Jump to char";
                on = ["f"];
              }
              {
                run = "filter";
                on = ["F"];
              }
              {
                run = "plugin smart-enter";
                desc = "Enter the child directory, or open the file";
                on = ["l"];
              }
              {
                run = "plugin smart-enter";
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
                      run = "plugin relative-motions ${idx}";
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
          hash = "sha256-LWN0riaUazQl3llTNNUMktG+7GLAHaG/IxNj1gFhDRE=";
        };
      in {
        toggle-pane = "${plugin-src}/toggle-pane.yazi";
        full-border = "${plugin-src}/full-border.yazi";
        jump-to-char = "${plugin-src}/jump-to-char.yazi";
        smart-enter = "${plugin-src}/smart-enter.yazi";
        relative-motions = pkgs.fetchgit {
          url = "https://github.com/dedukun/relative-motions.yazi";
          hash = "sha256-L5B5X762rBoxgKrUi0uRLDmAOJ/jPALc2bP9MYLiGYw=";
        };
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
          sep_left = {
            open = "";
            close = "";
          };
          sep_right = {
            open = "";
            close = "";
          };
        };
      };
    };

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
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
            right = 5;
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
        modules =
          [
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
          ]
          ++ builtins.genList (_: {
            type = "break";
            format = "";
          })
          4
          ++ [
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

              # Show that you are in nix-shell
              set -l nix_shell_info (
                if test -n "$IN_NIX_SHELL"
                  echo -n "nix-shell "
                end
              )
              set -l git (echo -n -s (fish_vcs_prompt | awk '{$1=$1};1') " ")

              echo -n -s "$git" (set_color $color_cwd) "$nix_shell_info$prompt_status" (set_color $color_cwd) "$suffix "

            '';
        };
        cheat = {
          body = "curl cheat.sh/$argv[1]";
        };
        octaveEnv = {
          body =
            /*
            sh
            */
            ''
              nix-shell -p "octave.withPackages (pkgs: with pkgs; [ $argv ])"
            '';
        };
      };
      plugins = with pkgs.fishPlugins; [
        {
          name = "fzf-fish";
          inherit (fzf-fish) src;
        }
        {
          name = "pisces";
          inherit (pisces) src;
        }
        {
          name = "colored-man-pages";
          inherit (colored-man-pages) src;
        }
      ];
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      escapeTime = 10;
      focusEvents = true;
      terminal = "tmux-256color";
      inherit (userSettings) shell;
      customPaneNavigationAndResize = true;
      resizeAmount = 2;
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
          cargoHash = "sha256-g/SYXAuR8SXewb80S+WcnvPLEQOa395OPUh0Qyf+JuY=";
        };
      in
        /*
        sh
        */
        ''
          set-option -sa terminal-features ',xterm-256color:RGB'

          set -g allow-passthrough all
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM

          bind | split-window -h -c '#{pane_current_path}'
          bind - split-window -v -c '#{pane_current_path}'

          setw -g monitor-activity on
          set -g visual-activity on
          set -g base-index 1

          # set -g status-left-length 85
          set -g status-right-length 90
          set -g status-style bg=default

          set -g status-left ' #S '
          set -g window-status-format " #I:#(${despell}/bin/despell #W) #W "
          set -g window-status-current-format "#[fg=#3b383e, bg=#a9dc76, bold] #I #[fg=#a9dc76,bg=#3b383e, bold] #(${despell}/bin/despell #W) #W "
          set -g status-right "#[fg=#3b383e, bg=#a9dc76, bold]  #[fg=#a9dc76,bg=#3b383e, bold] #(echo $(fish -c 'prompt_pwd $(tmux display-message -p \"#{pane_current_path}\")'))  #[default] "

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
          font = "${userSettings.mainFont}:size=12,${userSettings.jpFont}:size=12,NotoColorEmoji:size=11,${userSettings.nerdFont}:size=9";
          pad = "0x5";
          gamma-correct-blending = "no";
        };
        bell = {
          urgent = "no";
          notify = "no";
          command = "paplay ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/completion-partial.oga";
          command-focused = "yes";
        };
        colors = {
          # alpha=1.0
          background = "2b282d";
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

    mpv = {
      enable = true;
      package = (
        pkgs.mpv-unwrapped.wrapper {
          scripts = with pkgs.mpvScripts; [
            mpv-webm
            uosc
            thumbfast
          ];
          mpv = pkgs.mpv-unwrapped.override {
            waylandSupport = true;
          };
        }
      );
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
        ytdl-raw-options = "format-sort=height:720";
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
    mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        layer = "overlay";
        background-color = "#282A36";
        border-color = "#FFFFFF";
        default-timeout = 10000;
        icon-path = "${pkgs.kdePackages.oxygen-icons}/share/icons/oxygen/base";
        font = "${userSettings.mainFont} 10";
        format = ''<b>%s</b>\n%b'';
        on-button-middle = "invoke-action middle";
      };
    };

    mpd = {
      enable = true;
      musicDirectory = /. + "${userSettings.homeDirectory}/Music";
      dbFile = "~/.config/mpd/database";
      playlistDirectory = /. + "${userSettings.homeDirectory}/.config/mpd/playlists";
      dataDir = /. + "${userSettings.homeDirectory}/.config/mpd/state";
      network = {
        listenAddress = "/tmp/mpd_socket";
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

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = let
        imageType = {
          name = "image";
          program = ["swayimg.desktop"];
          formats = ["apng" "avif" "bmp" "gif" "vnd.microsoft.icon" "jpeg" "png" "tiff" "webp"];
        };
        videoType = {
          name = "video";
          program = ["mpv.desktop"];
          formats = ["x-msvideo" "mp4" "mpeg" "ogg" "mp2t" "webm" "3gpp" "3gpp2"];
        };
        generateMime = type:
          builtins.listToAttrs (builtins.map (format: {
              name = "${type.name}/${format}";
              value = type.program;
            })
            type.formats);
      in
        {
          "application/pdf" = ["org.pwmt.zathura.desktop"];
          "application/vnd.microsoft.portable-executable" = ["wine.desktop"];
          "text/html" = ["org.qutebrowser.qutebrowser.desktop"];
          "x-scheme-handler/https" = ["org.qutebrowser.qutebrowser.desktop"];
        }
        // generateMime imageType
        // generateMime videoType;
    };

    portal = {
      enable = true;
      config = {
        hyprland = {
          default = [
            "gtk"
            "hyprland"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [
            "kde"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [
            "hyprland"
          ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
    };

    desktopEntries = let
      mspaint-exe = pkgs.fetchzip {
        url = "https://ia804705.us.archive.org/3/items/MSPaintWinXP/mspaint%20WinXP%20English.zip";
        hash = "sha256-whRPXwzJSPbdUZZGAnl61SVANw7mnAZs8nN9TcA4LIU=";
      };
    in {
      "org.qutebrowser.qutebrowser" = {
        name = "qutebrowser";
        genericName = "Web Browser";
        icon = "qutebrowser";
        exec = "env QT_QPA_PLATFORMTHEME=qt6ct ${pkgs.qutebrowser}/bin/qutebrowser --untrusted-args %u";
        terminal = false;
        categories = ["Network" "WebBrowser"];
        mimeType = ["text/html" "text/xml" "application/xhtml+xml" "application/xml" "application/rdf+xml" "image/gif" "image/jpeg" "image/png" "image/webp" "x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/qute"];
      };
      hydrus-client = {
        name = "Hydrus Client";
        exec = "env QT_QPA_PLATFORMTHEME=qt6ct ${pkgs.hydrus}/bin/hydrus-client";
        icon = "hydrus-client";
        terminal = false;
      };
      fluent-reader = {
        name = "Fluent Reader";
        exec = "fluent-reader --no-sandbox %U --disable-gpu-driver-bug-workarounds";
        terminal = false;
        type = "Application";
        icon = "fluent-reader";
        categories = ["Utility"];
        comment = "Modern desktop RSS reader";
      };
      pavucontrol-qt = {
        exec = "env QT_QPA_PLATFORMTHEME=qt6ct pavucontrol-qt";
        name = "PulseAudio Volume Control";
        genericName = "Adjust volume levels and select audio devices";
        icon = "multimedia-volume-control";
      };
      mspaint = {
        name = "Microsoft Paint";
        exec = "wine ${mspaint-exe}/mspaint.exe";
        terminal = false;
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = let
    vencord_theme = {
      main = pkgs.fetchurl {
        url = "https://refact0r.github.io/system24/src/main.css";
        hash = "sha256-kh8YQddGrK4WT7aQDZolowSeXPXr9DUtPmvujac/XLk=";
        postFetch = ''
          patch -Np1 -F 3 $out ${self}/home-manager/patches/discord_theme.patch
        '';
      };
      unrounding = pkgs.fetchurl {
        url = "https://refact0r.github.io/system24/src/unrounding.css";
        hash = "sha256-8HLzvEzgh1M+F8BMMeGWoccCMFVr+Rjs2KToQwZNqyA=";
      };
    };
  in {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry-qt}/bin/pinentry-qt

    '';

    ".config/vesktop/themes/main.css".source = "${vencord_theme.main}";
    ".config/vesktop/themes/unrounding.css".source = "${vencord_theme.unrounding}";

    ".config/swayimg/config".text = lib.generators.toINI {} {
      general = {
        mode = "viewer";
        position = "parent";
        size = "parent";
        app_id = "swayimg";
      };
      viewer = {
        window = "#00000000";
        transparency = "#00000000";
        scale = "optimal";
        antialiasing = "no";
        fixed = "yes";
        slideshow = "no";
        slideshow_time = 3;
        history = 1;
        preload = 1;
      };
      gallery = {
        size = 120;
        cache = 100;
        fill = "yes";
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
      };
      font = {
        name = "${userSettings.jpFont}";
        size = 12;
        color = "#cccccc";
        shadow = "#000000a0";
      };
      info = {
        show = "yes";
        info_timeout = 5;
        status_timeout = 3;
      };
      "info.viewer" = {
        top_left = "name,format,filesize,imagesize,exif";
        top_right = "index";
        bottom_left = "scale,frame";
        bottom_right = "status";
      };
      "info.gallery" = {
        top_left = "none";
        top_right = "none";
        bottom_left = "none";
        bottom_right = "name,status";
      };
      "keys.viewer" = {
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
        "Shift+bar" = "flip_horizontal";
        a = "antialiasing";
        r = "reload";
        i = "info";
        e = "exec echo \"Image: %\"";
        Escape = "exit";
        q = "exit";
        ScrollLeft = "step_left 5";
        ScrollRight = "step_right 5";
        ScrollUp = "step_up 5";
        ScrollDown = "step_down 5";
        "Ctrl+ScrollUp" = "zoom +10";
        "Ctrl+ScrollDown" = "zoom -10";
        "Shift+ScrollUp" = "prev_file";
        "Shift+ScrollDown" = "next_file";
        "Alt+ScrollUp" = "prev_frame";
        "Alt+ScrollDown" = "next_frame";
      };
      "keys.gallery" = {
        Home = "first_file";
        End = "last_file";
        p = "prev_file";
        n = "next_file";
        Space = "next_file";
        Left = "step_left";
        Right = "step_right";
        Up = "step_up";
        Down = "step_down";
        h = "step_left";
        l = "step_right";
        k = "step_up";
        j = "step_down";
        a = "antialiasing";
        r = "reload";
        i = "info";
        e = "exec echo \"Image: %\"";
        Escape = "exit";
        q = "exit";
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
    GTK_USE_PORTAL = "1";
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
    rsshub = {
      Unit.Description = "Start instance of RSSHub";

      Service = {
        Environment = [
        ];
        ExecStart = "${pkgs.rsshub}/bin/rsshub";
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
