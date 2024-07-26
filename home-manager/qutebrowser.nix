{
  config,
  pkgs,
  userSettings,
  ...
}: let
  yomichad = pkgs.python3Packages.buildPythonPackage {
    name = "yomichad";
    src = pkgs.fetchFromGitHub {
      owner = "potamides";
      repo = "yomichad";
      rev = "167bddba92e5dc5e581a29feb3cb56a0c4e52acf";
      hash = "sha256-vTaq6ZoXAMgMmLOgRrx0lmR0w9QmPXQFT5UZNTZ/7MQ=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
      pyqt6
      (buildPythonPackage {
        pname = "puchikarui";
        version = "0.2a2.post5";
        src = pkgs.fetchFromGitHub {
          owner = "letuananh";
          repo = "puchikarui";
          rev = "6616d6fb9f131f2489ee3067fd981a19943e095f";
          hash = "sha256-Qct6Pdl3Li95f3LFZytmmJdQRTE3jGvLIOEtYG+p4Mo=";
        };

        doCheck = false;
      })
      (buildPythonPackage rec {
        pname = "chirptext";
        version = "0.1.2";
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-ZDycEVCPUJs3JX4/OmKaZowJCK5fWC17nxMSNKc3kwM=";
        };

        doCheck = false;
      })
      (buildPythonPackage rec {
        pname = "jamdict";
        version = "0.1a11.post2";
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-+7VN49WOzbm1NJiuhzq2UZMSyGvISKl2nZKxsjjUyRQ=";
        };

        doCheck = false;
      })
      (buildPythonPackage {
        pname = "jamdict-data";
        version = "1.5.1a2";
        src = pkgs.fetchFromGitHub {
          owner = "neocl";
          repo = "jamdict_data";
          rev = "f9c39bdfad6d60664d4f56493c4b6702ac7438f9";
          hash = "sha256-2HOSpIcBZ4VSoyHPYL4rGodj0+ADO202/6PgxNDVkg4=";
        };

        doCheck = false;
      })
    ];

    doCheck = false;

    preBuild = ''

      cat > setup.py << EOF
      from setuptools import setup

      with open('requirements.txt') as f:
          install_requires = f.read().splitlines()

      setup(
        name='yomichad',
        #packages=['someprogram'],
        version='0.1.0',
        #author='potamides'
        #description='...',
        install_requires=install_requires,
        scripts=[
          'yomichad',
        ],
        entry_points={
          # example: file some_module.py -> function main
          #'console_scripts': ['someprogram=some_module:main']
        },
      )
      EOF
    '';
  };
in {
  home.file.".config/qutebrowser/userscripts/yomichad".source = "${yomichad}/bin/yomichad";
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
        default_family = ["Hack Nerd Font" userSettings.emojiFont];
        prompts = userSettings.mainFont;
        default_size = "10pt";
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
    greasemonkey = let
      sponsorblock = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/master/youtube_sponsorblock.js";
        hash = "sha256-4piHtjbCDo2oBzUOlmdQpEgUqA3TEefzacGeqL0Pwk8=";
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
        hash = "sha256-pISk/Fhix1PHjxdyEh9fU8j7AyAGccYBsUMYfrapEBQ=";
        postFetch = ''
          patch -Np1 $out ${userSettings.flake-path}/home-manager/patches/control-panel-for-twitter.patch
        '';
      };
      disable-youtube-video-ads = pkgs.fetchurl {
        url = "https://update.greasyfork.org/scripts/32626/Disable%20YouTube%20Video%20Ads.user.js";
        hash = "sha256-/3j+aGeZ5cFuN3+1mMTquBB22702z9eX3ck6zB6kPt4=";
      };
    in [
      sponsorblock
      youtube-age-bypass
      _4chan-sounds-player
      _4chanX
      disable-youtube-video-ads
      control-panel-for-twitter
    ];
  };
}
