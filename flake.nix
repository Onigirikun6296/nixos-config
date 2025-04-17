{
  description = "Oni's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    disko,
    home-manager,
    nix-index-database,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    pkgs-stable = import nixpkgs-stable {
      inherit system;
    };

    systemSettings = {
      hostname = "Orion";
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

      term = "foot";
      file-manager = "dolphin";
      shell = "${pkgs.fish}/bin/fish";
    };
  in {
    formatter.${system} = pkgs.alejandra;
    nixosConfigurations = {
      Pegasus = lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disk-config.nix
          ./system/configuration.nix
          ./system/hardware-configuration.nix
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
          ./system/hardware-configuration.nix
          ./system/filesystems.nix
          # ./system/printer.nix
          ./system/bluetooth.nix
          ./system/steam.nix
        ];
        specialArgs = {
          inherit inputs;
          inherit systemSettings;
          inherit userSettings;
        };
      };
      Orion = lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disk-config.nix
          ./system/configuration.nix
          ./system/hardware-configuration.nix
          ./system/bluetooth.nix
        ];
        specialArgs = {
          inherit inputs;
          inherit systemSettings;
          inherit userSettings;
        };
      };
    };
    homeConfigurations = {
      oni = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.hmModules.nix-index
          ./home-manager/home.nix
          ./home-manager/email.nix
        ];
        extraSpecialArgs = {
          inherit userSettings;
          inherit self;
          inherit pkgs-stable;
        };
      };
    };
  };
}
