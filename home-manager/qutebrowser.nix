{
  config,
  pkgs,
  userSettings,
  ...
}: let
  sponsorblock = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/master/youtube_sponsorblock.js";
    hash = "sha256-nwNade1oHP+w5LGUPJSgAX1+nQZli4Rhe8FFUoF5mLE=";
  };
  youtube-age-bypass = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/master/dist/Simple-YouTube-Age-Restriction-Bypass.user.js";
    hash = "sha256-GxKKoB37xJOHnpTPhhp+xsIT6hebFkciJjvaMBbDFPk=";
  };
  _4chan-sounds-player = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rcc11/4chan-sounds-player/master/dist/4chan-sounds-player.user.js";
    hash = "sha256-o89sRpLYiMbNCc3oIr4qD6QHEZVaughwxsks20cPlJY=";
  };
  _4chanX = pkgs.fetchurl {
    url = "https://www.4chan-x.net/builds/4chan-X.user.js";
    hash = "sha256-asCbmIZ7PZyq7Uedr0hNiAWHwPPV8lLXw4EnsBh65Us=";
  };
  control-panel-for-twitter = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/insin/control-panel-for-twitter/master/script.js";
    hash = "sha256-jckaJCUv3g0yvNXawI0faiI0zs1H55gpWKq1uSf8QxI=";
    postFetch = ''
      sed -i 's/hideForYouTimeline: true/hideForYouTimeline: false/g' $out
    '';
  };
  disable-youtube-video-ads = pkgs.fetchurl {
    url = "https://update.greasyfork.org/scripts/32626/Disable%20YouTube%20Video%20Ads.user.js";
    hash = "sha256-/3j+aGeZ5cFuN3+1mMTquBB22702z9eX3ck6zB6kPt4=";
  };
in {
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    searchEngines = {
      DEFAULT = "https://duckduckgo.com/?ia=web&q={}";
      ddg = "https://duckduckgo.com/?ia=web&q={}";
      ddgi = "https://duckduckgo.com/?q={}&t=h_&start=1&iar=images&iax=images&ia=images";
      m = "https://duckduckgo.com/?t=h_&hps=1&q={}&ia=web&iaxm=maps";
      yt = "https://www.youtube.com/results?search_query={}";
      mal = "https://myanimelist.net/search/all?q={}&cat=all";
      t = "https://tenor.com/search/{}-gifs";
      pkgs = "https://search.nixos.org/packages?query={}";
    };
    aliases = {
      "q" = "close";
      "qa" = "quit";
      "w" = "session-save";
      "wq" = "quit --save";
      "wqa" = "quit --save";
    };
    keyBindings = {
      normal = {
        ",cm" = "config-cycle colors.webpage.darkmode.enabled";
        ",i" = "hint images spawn mpv {hint-url}";
        ",I" = "hint images download";
        ",m" = "spawn --userscript view_in_mpv";
        ",M" = "hint links spawn mpv {hint-url}";
        ";M" = "hint --rapid links spawn mpv {hint-url}";
        ";d" = "hint links download";
        ";D" = "hint --rapid links download";
        "eu" = "edit-url";
        "<return>" = "selection-follow";
        "zl" = "spawn --userscript qute-pass";
        "<Ctrl+Shift+T>" = "spawn --userscript translate";
        "<Ctrl+T>" = "spawn --userscript translate --text";
        "xt" = "config-cycle tabs.show.multiple switching";
        "gs" = "spawn --userscript yomichad --names";
        "gS" = "spawn --userscript yomichad --prefix-search";
      };
    };

    settings = {
      fonts = {
        default_family = [userSettings.mainFont userSettings.jpFont userSettings.emojiFont];
        prompts = userSettings.mainFont;
        default_size = "14pt";
      };
      content = {
        notifications = {
          presenter = "libnotify";
          show_origin = false;
        };
        blocking = {
          enabled = true;
          method = "adblock";
        };
        javascript.clipboard = "access";
        pdfjs = true;
      };
      tabs.show = "multiple";
      auto_save.session = true;
      spellcheck.languages = ["en-GB" "el-GR"];
      scrolling.smooth = true;
    };
    extraConfig =
      /*
      python
      */
      ''
        import sys, os

        settings = {

                # Fingerprint Settings
                # 'content.headers.user_agent'        : 'Mozilla/5.0 (X11; Linux x86_64; rv:101.0) Gecko/20100101 Firefox/106.0',
                # 'content.headers.accept_language'   : 'en-US,en;q=0.5',
                # 'content.headers.custom'            : {"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"},

                # Tor
                # 'content.proxy'                   : 'socks://localhost:9050',

                # Fonts

                # Misc
                'editor.command'                    : ['${userSettings.term}', 'nvim', '-f','{file}', '-c', 'normal {line}G{column0}l'],

                # Adblock lists
                'content.blocking.adblock.lists'    : [
                                                        "https://easylist-downloads.adblockplus.org/easylist.txt",
                                                        "https://easylist-downloads.adblockplus.org/easyprivacy.txt",
                                                        "https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt",
                                                        "https://easylist-downloads.adblockplus.org/fanboy-social.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt",
                                                        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
                                                      ]
        }

        for setting, value in settings.items():
            config.set(setting, value)

      '';
    greasemonkey = [
      sponsorblock
      youtube-age-bypass
      _4chan-sounds-player
      _4chanX
      disable-youtube-video-ads
      control-panel-for-twitter
    ];
  };
}
