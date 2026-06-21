{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  userSettings,
  systemSettings,
  ...
}:
let
  displays = {
    Sagittarius = {
      monitor = "LVDS-1";
      resolution = "1600x900";
    };
    Orion = {
      monitor = "HDMI-A-1";
      resolution = "1920x1080";
    };
    default = {
      monitor = "";
      resolution = "preferred";
    };
  };
  getDisplay = hostname: if displays ? ${hostname} then displays.${hostname} else displays.default;

  display = getDisplay systemSettings.hostname;

  wallpaper = userSettings.wallpaper;
  lock_wallpaper = userSettings.lock_wallpaper;
  term = "${pkgs.foot}/bin/foot";
  file-manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  cursor = pkgs.fetchgit {
    url = "https://github.com/OtaK/McMojave-hyprcursor";
    hash = "sha256-+Qo88EJC0nYDj9FDsNtoA4nttck81J9CQFgtrP4eBjk=";
  };
in
{
  home.file.".local/share/icons/McMojave/" = {
    source = "${cursor}/dist/";
    recursive = true;
  };
  home.sessionVariables = {
    HYPRCURSOR_THEME = "McMojave";
    HYPRCURSOR_SIZE = "32";
  };
  programs = {
    hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };
        cursor = {
          no_hardware_cursors = true;
        };
        background = [
          {
            path = lock_wallpaper;
            color = "rgba(25, 20, 20, 1.0)";
            blur_passes = 1;
            blur_size = 7;
            noise = 0.0117;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.9696;
            vibrancy_darkness = 0.0;
          }
        ];
        input-field = [
          {
            size = "200, 25";
            outline_thickness = 0;
            dots_size = 0.13;
            dots_spacing = 0.55;
            dots_center = true;
            dots_rounding = 2;
            outer_color = "rgb(151515)";
            inner_color = "rgb(250, 250, 250)";
            font_color = "rgb(10, 10, 10)";
            fade_on_empty = false;
            fade_timeout = 1000;
            placeholder_text = "<span foreground='##0A0A0A'><i>Input Password...</i></span>";
            hide_input = false;
            rounding = 5;
            check_color = "rgb(204, 136, 34)";
            fail_color = "rgb(204, 34, 34)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            capslock_color = -1;
            numlock_color = -1;
            bothlock_color = -1;
            invert_numlock = false;
            position = "0, -60";
            halign = "center";
            valign = "center";
          }
        ];
        image = [
          {
            path = "$HOME/.config/hypr/pfp.png";
            size = 150;
            rounding = -1;
            border_size = 4;
            border_color = "rgb(211, 211, 211)";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
        label = [
          {
            text = "お帰り、$USERくん";
            color = "rgba(250, 250, 250, 1.0)";
            font_size = 12;
            font_family = userSettings.jpFont;
            rotate = 0;
            position = "0, -24";
            halign = "center";
            valign = "center";
          }
          {
            text = "cmd[update:1000] echo \"$(date +\"%a %b %d %r %Y\")\"";
            color = "rgba(250, 250, 250, 1.0)";
            font_size = 12;
            font_family = userSettings.jpFont;
            position = "0, 10";
            halign = "center";
            valign = "bottom";
          }
          {
            text = ''cmd[update:1000] echo "$(if [  -n "$(${pkgs-unstable.rmpc}/bin/rmpc song 2>/dev/null)" ]; then echo "🎧 Now playing: $(${pkgs-unstable.rmpc}/bin/rmpc song | jq '.metadata | .artist, .album ' | xargs printf \"%s-%s\")"; fi)"'';
            color = "rgba(250, 250, 250, 1.0)";
            font_size = 12;
            font_family = userSettings.jpFont;
            position = "0, 40";
            halign = "center";
            valign = "bottom";
          }
        ];
      };
    };
  };

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 500;
            on-timeout = "loginctl lock-session && hyprctl dispatch dmps off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 500;
            on-timeout = "loginctl lock-session && hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = "false";
        preload = [ wallpaper ];
        wallpaper = [
          {
            monitor = display.monitor;
            path = wallpaper;
            fit_mode = "cover";
          }
        ];
      };
    };
  };

  wayland.windowManager.hyprland =
    let
      lua = lib.generators.mkLuaInline;
      dsp = {
        exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
        close = lua "hl.dsp.window.close()";
        exit = lua "hl.dsp.exit()";
        float = lua ''hl.dsp.window.float({ action = "toggle" })'';
        fullscreen = lua "hl.dsp.window.fullscreen()";
        pseudo = lua "hl.dsp.window.pseudo()";
        layout = msg: lua ''hl.dsp.layout("${msg}")'';
        focus = dir: lua ''hl.dsp.focus({direction = "${dir}"})'';
        swap = dir: lua ''hl.dsp.window.swap({direction = "${dir}"})'';
        focusWorkspace = ws: lua ''hl.dsp.focus({workspace = "${toString ws}"})'';
        moveToWorkspace = ws: lua ''hl.dsp.window.move({workspace = "${toString ws}", follow = false})'';
        drag = lua "hl.dsp.window.drag()";
        resize = lua "hl.dsp.window.resize()";
        resizeWindow =
          x: y: lua "hl.dsp.window.resize({x = ${toString x}, y = ${toString y}, relative = true})";
        sendshortcut = mod: key: lua ''hl.dsp.send_shortcut({ mods = "${mod}", key = "${key}" })'';

      };
      bind = keys: dispatcher: {
        _args = [
          keys
          dispatcher
        ];
      };
      bindOpts = keys: dispatcher: opts: {
        _args = [
          keys
          dispatcher
          opts
        ];
      };
      workspaceBinds = lib.concatMap (
        i:
        let
          key = toString (lib.mod i 10);
        in
        [
          (bind "SUPER + ${key}" (dsp.focusWorkspace i))
          (bind "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i))
        ]
      ) (lib.range 1 10);
      startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
        pypr &
        hyprland-autoname-workspaces &
        paplay ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/desktop-login.oga &
      '';
    in
    {
      enable = true;
      configType = "lua";
      settings = {
        monitor = [
          {
            output = display.monitor;
            mode = display.resolution;
            position = "0x0";
            scale = "1.0";
          }
        ];
        config = {

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;

            col = {
              active_border = "rgba(ff0c0fee)";
              inactive_border = "rgb(151515)";
            };
            layout = "master";
          };

          decoration = {
            blur = {
              enabled = true;
            };
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };
          };

          animations = {
            enabled = true;
          };

          input = {
            kb_layout = "us";
            kb_options = "caps:escape";
            follow_mouse = true;
            touchpad = {
              natural_scroll = false;
              disable_while_typing = true;
            };
            sensitivity = 0;
            repeat_rate = 60;
            repeat_delay = 300;
          };
          device = [
            {
              name = "ps/2-generic-mouse";
              accel_profile = "flat";
              sensitivity = "+1.0";
            }
          ];
          master = {
            new_status = "slave";
            orientation = "left";
          };
          misc = {
            disable_splash_rendering = true;
            enable_swallow = true;
            swallow_regex = "^(foot)$";
            # vfr = "true";
          };
        };
        curve = [
          {
            _args = [
              "myBezier"
              {
                type = "bezier";
                points = lua "{ {0.05, 0.9}, {0.1, 1.05} }";
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 7;
            bezier = "myBezier";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 7;
            bezier = "default";
            style = "popin 80%";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 8;
            bezier = "default";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 7;
            bezier = "default";
          }
          {
            leaf = "workspaces";
            enabled = false;
            speed = 6;
            bezier = "default";
          }
        ];
        on = {
          _args = [
            "hyprland.start"
            (lua ''
              function()
                hl.exec_cmd("${startupScript}/bin/start")
              end'')
          ];
        };

        bind = [
          (bind "SUPER + SHIFT + Q" dsp.close)
          (bind "SUPER + SHIFT + RETURN" (dsp.exec "${term} tmux"))
          (bind "SUPER + SHIFT + SPACE" dsp.float)
          (bind "SUPER + SHIFT + G" (dsp.exec "${term} btm"))
          (bind "SUPER + SHIFT + D" (dsp.exec "${file-manager}"))
          (bind "SUPER + TAB" (dsp.exec "${term} yazi"))
          (bind "SUPER + Print" (dsp.exec "$HOME/.scripts/prtsc.sh active"))
          (bind "SUPER + SHIFT + Print" (dsp.exec "$HOME/.scripts/prtsc.sh area"))
          (bind "SUPER + SHIFT + minus" (dsp.exec "$HOME/.scripts/gaps.sh dec"))
          (bind "SUPER + SHIFT + equal" (dsp.exec "$HOME/.scripts/gaps.sh inc"))
          (bind "SUPER + equal" (dsp.exec "$HOME/.scripts/gaps.sh reset"))
          (bind "SUPER + grave" (dsp.exec "pypr toggle term"))
          (bind "SUPER + n" (dsp.exec "pypr toggle rmpc"))
          (bind "SUPER + m" (dsp.exec "pypr toggle mail"))
          (bind "SUPER + u" (dsp.exec "pypr show unicode"))
          (bind "SUPER + a" (dsp.exec "pypr toggle agenda"))
          # " SUPER,y,exec,pypr toggle youtube"
          (bind "SUPER + R" (dsp.exec "bemenu-run --fn \'${userSettings.mainFont} 14\' -H 24"))
          (bind "SUPER + P" (dsp.exec "rofi -show-icons -show drun"))
          (bind "SUPER + left" (dsp.focus "left"))
          (bind "SUPER + right" (dsp.focus "right"))
          (bind "SUPER + up" (dsp.focus "up"))
          (bind "SUPER + down" (dsp.focus "down"))
          (bind "SUPER + k" (dsp.layout "cycleprev"))
          (bind "SUPER + j" (dsp.layout "cyclenext"))
          (bind "SUPER + SHIFT + k" (dsp.layout "swapprev"))
          (bind "SUPER + SHIFT + j" (dsp.layout "swapnext"))
          (bind "SUPER + RETURN" (dsp.layout "swapwithmaster"))
          (bind "SUPER + SHIFT + h" (dsp.swap "left"))
          (bind "SUPER + SHIFT + l" (dsp.swap "right"))
          (bind "SUPER + SHIFT + k" (dsp.swap "up"))
          (bind "SUPER + SHIFT + j" (dsp.swap "down"))
          (bind "SUPER + SHIFT + F" (dsp.fullscreen))
          (bind "SUPER + F3" (dsp.exec "hyprlock"))
          (bindOpts "XF86AudioMicMute" (dsp.exec "pactl set-source-mute @DEFAULT_SOURCE@ toggle") {
            locked = true;
          })
          (bindOpts "XF86AudioRaiseVolume" (dsp.exec "~/.scripts/changeVolume +5%") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86AudioLowerVolume" (dsp.exec "~/.scripts/changeVolume -5%") {
            locked = true;
            repeating = true;
          })
          (bindOpts "SUPER + mouse:272" dsp.drag { mouse = true; })
          (bindOpts "SUPER + mouse:273" dsp.resize { mouse = true; })
          (bindOpts "SUPER + h" (dsp.resizeWindow (-100) 0) { repeat = true; })
          (bindOpts "SUPER + l" (dsp.resizeWindow 100 0) { repeat = true; })
        ]
        ++ workspaceBinds;
      };
    };

  home.file.".config/pypr/config.toml".source = (pkgs.formats.toml { }).generate "config.toml" {
    pyprland = {
      plugins = [ "scratchpads" ];
    };
    scratchpads = {
      term = {
        animation = "fromTop";
        command = "${term} -a foot-scratchpad tmux new -A -s scratch";
        class = "foot-scratchpad";
        position = "25% 29px";
        size = "50% 50%";
        max_size = "2900px 100%";
      };
      rmpc = {
        animation = "fromTop";
        command = "${term} -a rmpc-scratchpad rmpc";
        class = "rmpc-scratchpad";
        position = "15% 29px";
        size = "70% 60%";
        max_size = "2900px 100%";
      };
      mail = {
        animation = "fromTop";
        command = "${term} -a mail-scratchpad neomutt";
        class = "mail-scratchpad";
        position = "20% 29px";
        size = "60% 60%";
        max_size = "2900px 100%";
      };
      agenda = {
        animation = "fromTop";
        command = "${term} -a agenda-scratchpad nvim ~/orgfiles/agenda.org";
        class = "agenda-scratchpad";
        position = "25% 29px";
        size = "50% 50%";
        max_size = "2900px 100%";
      };
      # youtube = {
      #   animation = "fromLeft";
      #   command = "${pkgs.mpv}/bin/mpv --idle=yes --input-ipc-server=/tmp/mpvsocket";
      #   class = "youtube-scratchpad";
      #   position = "1% 57%";
      #   size = "364px 364px";
      #   max_size = "2900px 100%";
      # };
    };
  };
}
