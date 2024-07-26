{
  description = "Oni's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    systemSettings = {
      hostname = "nixos";
      timezone = "Some/Place";
      locale = "en_US.UTF-8";
    };

    userSettings = rec {
      username = "oni";
      homeDirectory = "/home/${username}";

      name = "Oni";
      email = "oni@onigiribentou.com";

      mainFont = "Ttyp0";
      jpFont = "Unifont";
      nerdFont = "Hack Nerd Font";
      emojiFont = "Noto Color Emoji";

      term = "${pkgs.foot}/bin/foot";
      file-manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      shell = "${pkgs.fish}/bin/fish";
	  flake-path = "${self}";
    };
  in {
    formatter.${system} = pkgs.alejandra;
    nixosConfigurations = {
      Pegasus = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
          ./system/virtualbox.nix
        ];
        specialArgs = {
          inherit systemSettings;
          inherit userSettings;
        };
      };
      Sagittarius = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
          ./system/filesystems.nix
          ./system/printer.nix
          ./system/bluetooth.nix
          ./system/steam.nix
        ];
        specialArgs = {
          inherit systemSettings;
          inherit userSettings;
        };
      };
    };
    homeConfigurations = {
      oni = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/home.nix
          ./home-manager/email.nix
        ];
        extraSpecialArgs = {
          inherit userSettings;
        };
      };
    };
  };
}
