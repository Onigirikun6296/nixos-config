{
  config,
  pkgs,
  userSettings,
  ...
}: let
  twitter = {
    username = "<twitter-username>";
    password = "<twitter-password>";
  };
  pixiv = {
    refresh-token = "<pixiv-refresh-token>";
  };
in {
  programs.gallery-dl = {
    enable = true;
    settings = {
      extractor = {
        twitter = {
          username = twitter.username;
          password = twitter.password;
          retweets = true;
          directory = {
            retweet_id = ["{category}" "{user[name]}" "Retweets" "{author[name]}"];
            "" = ["{category}" "{user[name]}"];
          };
        };

        pixiv = {
          filename = "{id}{num}.{extension}";
          directory = ["Pixiv" "Works" "{user[id]}"];
          refresh-token = pixiv.refresh-token;
          ugoira = true;
          postprocessors = ["ugoira-copy"];
          favorite = {
            directory = ["Pixiv" "Favourites" "{user[id]}"];
          };
        };
      };

      downloader = {
      };

      output = {
      };

      postprocessor = {
        ugoira-copy = {
          name = "ugoira";
          extension = "mkv";
          ffmpeg-args = ["-c" "copy"];
          libx264-prevent-odd = false;
          repeat-last-frame = false;
        };
      };
    };
  };
}
