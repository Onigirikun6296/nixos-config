{
  pkgs,
  pkgs-stable,
  userSettings,
  self,
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
      nwiki = "https://wiki.nixos.org/w/index.php?search={}";
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
        "xt" = "config-cycle tabs.show multiple switching";
        "gs" = "spawn --userscript yomichad --names";
        "gS" = "spawn --userscript yomichad --prefix-search";
      };
    };

    settings = {
      fonts = {
        default_family = [(userSettings.jpFont + "[GNU ]") userSettings.emojiFont];
        default_size = "12pt";
      };
      content = {
        # proxy = "socks://localhost:9050";
        notifications = {
          presenter = "libnotify";
          show_origin = false;
        };
        blocking = {
          enabled = true;
          method = "both";
          hosts.lists = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://raw.githubusercontent.com/laylavish/uBlockOrigin-HUGE-AI-Blocklist/main/noai_hosts.txt"
          ];
          adblock.lists = [
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/easylist.txt"
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/easyprivacy.txt"
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/fanboy-annoyance.txt"
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/fanboy-newsletter.txt"
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/fanboy-social.txt"
            "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/fanboy-sounds.txt"
          ];
        };
        javascript.clipboard = "access";
        pdfjs = true;
      };
      tabs.show = "multiple";
      tabs.title.format = "{audio}{relative_index}: {current_title}";
      auto_save.session = true;
      spellcheck.languages = ["en-GB" "el-GR"];
      scrolling.smooth = true;
      editor.command = ["${userSettings.term}" "nvim" "-f" "{file}" "-c" "normal {line}G{column0}l"];
    };
    extraConfig =
      /*
      python
      */
      ''
        from qutebrowser.api import interceptor


        def filter_yt(info: interceptor.Request):
            """Block the given request if necessary."""
            url = info.request_url
            if (
                url.host() == "www.youtube.com"
                and url.path() == "/get_video_info"
                and "&adformat=" in url.query()
            ):
                info.block()


        interceptor.register(filter_yt)


      '';

    greasemonkey = let
      sponsorblock = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/master/youtube_sponsorblock.js";
        hash = "sha256-nwNade1oHP+w5LGUPJSgAX1+nQZli4Rhe8FFUoF5mLE=";
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
        hash = "sha256-oAoGV7vr75KV5zPkUnzri7C3ATwTlk2kGeboNOlHdCs=";
        postFetch = ''
          patch -Np1 $out ${self}/home-manager/patches/control-panel-for-twitter.patch
        '';
      };
      return-youtube-dislike = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Anarios/return-youtube-dislike/refs/heads/main/Extensions/UserScript/Return%20Youtube%20Dislike.user.js";
        hash = "sha256-BPRgJOQfxTUmr09fqGi1dlZ14jtZfdKHhKltqmf5B+Y=";
      };
      adguard-youtube-adb = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Vendicated/Vencord/refs/heads/main/src/plugins/youtubeAdblock.desktop/adguard.js";
        hash = "sha256-z8se8YCrZYU+DshpewXyXPZr/DI9vKBgS1q5kVLmvkE=";
        postFetch = ''
          patch -Np1 $out ${self}/home-manager/patches/adguard.patch
        '';
      };
      twitter-plus = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Pixmi/twitter-plus/refs/heads/main/twitter-plus.user.js";
        hash = "sha256-bWUTo3+jxlGqCaKSZ/bEgPoZd5VAeNnt52fJfbamXNc=";
      };
      gelbooru-adb =
        pkgs.writeText "GelbooruADB.js"
        /*
        javascript
        */
        ''
          // ==UserScript==
          // @name         Gelbooru Ad Block
          // @version      0.0.1
          // @description  Remove gelbooru header and footer ads
          // @author       me
          // @match        *://*.gelbooru.com/*
          // @run-at      document-start
          // ==/UserScript==
          let p = new Promise((resolve) => {
             let id = setInterval(() => {
                 try {
                    [...document.querySelectorAll("[id$=container]")].slice(1).forEach(e => e.parentElement.remove())
                    document.querySelectorAll(".headerAd, .footerAd").forEach(e => e.remove());
                 } catch (e) {
                     console.error(e)
                 }
             }, 50)
             window.addEventListener('load', () => {
                resolve(id)
             })
          })
          p.then((id) => {
              clearInterval(id)
          })
        '';
    in [
      sponsorblock
      _4chan-sounds-player
      _4chanX
      control-panel-for-twitter
      return-youtube-dislike
      twitter-plus
      gelbooru-adb
      # adguard-youtube-adb
    ];
  };
}
