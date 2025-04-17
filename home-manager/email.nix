{pkgs, ...}: let
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
    pythonFile =
      /*
      python
      */
      ''
        #!/usr/bin/env python2
        from subprocess import check_output

        def get_pass(account):
            return check_output("${pkgs.pass}/bin/pass " + account, shell = True).splitlines()[0]


        if __name__ == "__main__":
            print(get_pass())

      '';
  };

  systemd.user.services = let
    createEmailServices = emails:
      builtins.listToAttrs (builtins.map (email: {
          name = "offlineimap@${email}";
          value = {
            Unit.Description = "Offlineimap Service for account ${email}";

            Service = {
              ExecStart = "${pkgs.offlineimap}/bin/offlineimap -u basic -a ${email}";
              Restart = "on-failure";
              RestartSec = 60;
            };
            Install.WantedBy = ["default.target"];
          };
        })
        emails);
  in
    {} // createEmailServices [primary.name secondary.name];

  accounts.email.accounts = {
    "${primary.name}" = {
      primary = true;
      address = "${primary.address}";
      imap.host = "imap.gmail.com";
      offlineimap = {
        enable = true;
        extraConfig = {
          account.autorefresh = "1.0";
          local = {
            type = "Maildir";
            localfolders = "~/Storage/.mail/${primary.name}/";
            localrepository = "${primary.name}-local";
            remoterepository = "${primary.name}-remote";
          };

          remote = {
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
