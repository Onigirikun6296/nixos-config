{userSettings, ...}: {
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = [];
        modules-right = ["mpd" "bluetooth" "network" "memory" "temperature" "battery" "clock" "tray"];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
        };

        memory = {
          interval = 3;
          format = " {used:0.1f}G/{total:0.1f}G";
        };

        temperature = {
          critical-threshold = 80;
          format = " {temperatureC}°C";
        };
        battery = {
          format = "{icon}  {capacity}%";
          format-icons = ["" "" "" "" ""];
          states = {
            critical = 15;
          };
        };
        clock = {
          format = "{:%A %d %B %R}";
        };
        tray = {
          spacing = 10;
        };

        network = {
          interface = "wlp3s0";
          format = "{ifname}";
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "  {ipaddr}/{cidr}";
          format-disconnected = "";
          tooltip-format = "  {ifname} via {gwaddr}";
          tooltip-format-wifi = " { essid} ({signalStrength}%)";
          tooltip-format-ethernet = "  {ifname}";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        };

        mpd = {
          format = "{stateIcon} {randomIcon}{repeatIcon}{singleIcon} {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
          title-len = 50;
          format-disconnected = "Disconnected ";
          format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
          interval = 10;
          consume-icons = {
            on = " ";
          };
          random-icons = {
            off = "";
            on = " ";
          };
          repeat-icons = {
            on = " ";
          };
          single-icons = {
            on = "1 ";
          };
          state-icons = {
            paused = " ";
            playing = " ";
          };
          tooltip-format = "    MPD (connected)\n{title}\n{artist} - {album}";
          tooltip-format-disconnected = "MPD (disconnected)";
        };
      };
    };

    style =
      /*
      css
      */
      ''

        * {
          border: none;
          font-family: "${userSettings.mainFont}", ${userSettings.jpFont};
          font-size: 14px;
        }

        tooltip {
          background: rgba(43, 48, 59, 0.7);
          border: 1px solid rgba(100, 114, 125, 0.5);
        }
        tooltip label {
          font-size: 14px;
          color: white;
        }

        #mpd {
          font-family: "${userSettings.mainFont}", "${userSettings.jpFont}", "${userSettings.nerdFont}";
        }

        #workspaces button {
          padding-top: 0;
          padding-bottom: 0;
          border-radius: 0;
          color: white;
        }


        #mpd,
        #bluetooth,
        #battery,
        #clock,
        #tray,
        #temperature,
        #memory,
        #network {
          margin-right: 15px;
        }


        #battery.critical:not(charging) {
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #temperature.critical {
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        @keyframes blink {
          to {
            color: #f53c3c;
          }
        }

        #mode, #window {
          margin-left: 20px;
          color: white;
        }

        window#waybar {
          background: rgba(43, 48, 59, 0.7);
          color: white;
        }

        #temperature.critical {
          color: red;
        }

      '';
  };
}
