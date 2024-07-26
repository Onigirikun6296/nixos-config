{
  config,
  pkgs,
  userSettings,
  ...
}: let
  display = "LVDS-1";
  resolution = "1600x900";
  wallpaper = "${userSettings.homeDirectory}/Pictures/Wallpapers/1716425059533734.jpg";
  lock_wallpaper = "${userSettings.homeDirectory}/Pictures/Wallpapers/1716425059533734.jpg";
in {
  programs = {
    hyprlock = let
      jpFont = builtins.replaceStrings ["[GNU ]"] [""] "${userSettings.jpFont}";
    in {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
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
            font_family = jpFont;
            rotate = 0;
            position = "0, -24";
            halign = "center";
            valign = "center";
          }
          {
            text = "cmd[update:1000] echo \"$(date +\"%a %b %d %r %Y\")\"";
            color = "rgba(250, 250, 250, 1.0)";
            font_size = 12;
            font_family = jpFont;
            position = "0, 10";
            halign = "center";
            valign = "borrom";
          }
          {
            text = ''cmd[update:1000] echo "$(if [  -n "$(${pkgs.mpc-cli}/bin/mpc  2>/dev/null)" ]; then echo "🎧 Now playing: $(${pkgs.mpc-cli}/bin/mpc | head -n 1)"; fi)"'';
            color = "rgba(250, 250, 250, 1.0)";
            font_size = 12;
            font_family = jpFont;
            position = "0, 40";
            halign = "center";
            valign = "borrom";
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
        preload = [wallpaper];
        wallpaper = ["${display},${wallpaper}"];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = "${display},${resolution},0x0,1";
      exec-once = [
        "waybar"
        "pypr"
        "fcitx5 -d"
        "paplay ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/desktop-login.oga"
      ];
      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        follow_mouse = "1";
        touchpad = {
          natural_scroll = "no";
          disable_while_typing = "true";
        };
        sensitivity = "0";
        repeat_rate = "60";
        repeat_delay = "300";
      };
      device = {
        name = "ps/2-generic-mouse";
        accel_profile = "flat";
        sensitivity = "+1.0";
      };
      general = {
        gaps_in = "5";
        gaps_out = "10";
        border_size = "2";
        "col.active_border" = "rgba(ff0c0fee) rgba(af0f09ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "master";
      };
      decoration = {
        drop_shadow = "yes";
        shadow_range = "4";
        shadow_render_power = "3";
        "col.shadow" = "rgba(1a1a1aee)";
      };
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 0, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 0, 7, default"
          "workspaces, 0, 6, default"
        ];
      };
      master = {
        new_status = "slave";
        no_gaps_when_only = "false";
        orientation = "left";
      };
      misc = {
        disable_splash_rendering = "true";
        enable_swallow = "true";
        swallow_regex = "^(foot)$";
        vfr = "true";
      };
      windowrulev2 = [
        "float,title:^(hydrus client booting)$ "
        "float,title:^(hydrus client exiting)(.*)$"
        "move cursor -50% -50%,title:^(new page — hydrus client)(.*)$"
        "float, title:^(yomichad)$"
        "move cursor -50% -50%, title:^(yomichad)$"
      ];
      "$mod" = "SUPER";
      bind =
        [
          " $mod SHIFT, Q, killactive, "
          " $mod SHIFT, Return, exec, ${userSettings.term} tmux"
          " $mod SHIFT, Space, togglefloating, "
          " $mod SHIFT, G, exec, ${userSettings.term} btm"
          " $mod SHIFT, D, exec, ${userSettings.file-manager}"
          " $mod, Tab, exec, ${userSettings.term} yazi "
          " $mod, Print, exec, $HOME/.scripts/prtsc.sh"
          " $mod SHIFT, minus, exec, $HOME/.scripts/gaps.sh dec"
          " $mod SHIFT, equal, exec, $HOME/.scripts/gaps.sh inc"
          " $mod, equal, exec, $HOME/.scripts/gaps.sh reset"
          " $mod, F3, exec, hyprlock"
          " , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
          " , XF86AudioRaiseVolume, exec, ~/.scripts/changeVolume +5%"
          " , XF86AudioLowerVolume, exec, ~/.scripts/changeVolume -5%"
          " , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
          " $mod,grave,exec,pypr toggle term"
          " $mod,n,exec,pypr toggle ncmpcpp"
          " $mod,m,exec,pypr toggle mail"
          " $mod,u,exec,pypr show unicode"
          " $mod,a,exec,pypr toggle agenda"
          " $mod, P, exec, bemenu-run --fn \"${userSettings.mainFont} 14\" -H 24"
          " $mod, R, exec, rofi -show-icons -show drun"
          " $mod, left, movefocus, l"
          " $mod, right, movefocus, r"
          " $mod, up, movefocus, u"
          " $mod, down, movefocus, d"
          " $mod, h, movefocus, l"
          " $mod, l, movefocus, r"
          " $mod, k, layoutmsg, cycleprev"
          " $mod, j, layoutmsg, cyclenext"
          " $mod, h, resizeactive, -100 0"
          " $mod, l, resizeactive, 100 0"
          " $mod, Return, layoutmsg, swapwithmaster"
          " $mod SHIFT, k, layoutmsg, swapprev"
          " $mod SHIFT, j, layoutmsg, swapnext"
          " $mod SHIFT, f, fullscreen"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
              ]
            )
            10)
        );

      bindm = [
        " $mod, mouse:272, movewindow"
        " $mod, mouse:273, resizewindow"
      ];

      xwayland = {
        force_zero_scaling = true;
      };
    };
  };

  home.file.".config/hypr/pyprland.toml".source = (pkgs.formats.toml {}).generate "pyprland.toml" {
    pyprland = {
      plugins = ["scratchpads"];
    };
    scratchpads = {
      term = {
        animation = "fromTop";
        command = "${userSettings.term} -a foot-scratchpad tmux new -A -s scratch";
        class = "foot-scratchpad";
        position = "25% 29px";
        size = "50% 50%";
        max_size = "2900px 100%";
      };
      ncmpcpp = {
        animation = "fromTop";
        command = "${userSettings.term} -a ncmpcpp-scratchpad ncmpcpp";
        class = "ncmpcpp-scratchpad";
        position = "20% 29px";
        size = "60% 50%";
        max_size = "2900px 100%";
      };
      mail = {
        animation = "fromTop";
        command = "${userSettings.term} -a mail-scratchpad neomutt";
        class = "mail-scratchpad";
        position = "20% 29px";
        size = "60% 60%";
        max_size = "2900px 100%";
      };
      agenda = {
        animation = "fromTop";
        command = "${userSettings.term} -a agenda-scratchpad nvim ~/orgfiles/agenda.org";
        class = "agenda-scratchpad";
        position = "25% 29px";
        size = "50% 50%";
        max_size = "2900px 100%";
      };
    };
  };
}
