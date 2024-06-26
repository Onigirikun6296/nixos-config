{
  config,
  pkgs,
  userSettings,
  ...
}: let
  primary = {
    name = "gmail";
    address = "<enter-gmail-here>@gmail.com";
  };
  secondary = {
    name = "<secondary-account>";
    user = "<secondary-username>";
    address = "<secondary-email>";
  };
in {
  programs.offlineimap = {
    enable = true;
    pythonFile = ''
      #!/usr/bin/env python2
      from subprocess import check_output

      def get_pass(account):
          return check_output("pass " + account, shell = True).splitlines()[0]


      if __name__ == "__main__":
          print(get_pass())

    '';
  };
  accounts.email.accounts = {
    "${primary.name}" = {
      primary = true;
      address = "${primary.address}";
      imap.host = "imap.gmail.com";
      offlineimap = {
        enable = true;
        extraConfig = {
          local = {
            type = "Maildir";
            localfolders = "~/Storage/.mail/${primary.name}/";
            localrepository = "${primary.name}-local";
            remoterepository = "${primary.name}-remote";
          };

          remote = {
            maxconnections = "1";
            type = "Gmail";
            remoteuser = "${primary.address}";
            remotepasseval = ''get_pass("gmail_app_pass")'';
            realdelete = "yes";
            folderfilter = ''
              lambda folder: folder not in [
                                     '[Gmail]/All Mail',
                                     '[Gmail]/Trash',
                                     '[Gmail]/Important',
                                     '[Gmail]/Spam',
                                     ]'';
            sslcacertfile = "/etc/ssl/certs/ca-certificates.crt";
          };
        };
      };
    };
  };
}
