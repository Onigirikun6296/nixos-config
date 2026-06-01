{
  description = "Oni's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    nvf = {
      url = "github:NotAShelf/nvf/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    disko,
    home-manager,
    nix-index-database,
    nvf,
    sops-nix,
    nixos-hardware,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
    };

    systemSettings = {
      hostname = "Orion";
      timezone = "Some/Place";
      locale = "en_US.UTF-8";
    };

    userSettings = rec {
      username = "oni";

      name = "Oni";
      email = "oni@onigiribentou.com";
      wallpaper ="$HOME/Pictures/Wallpapers/pexels-strannik-sk-31794296.jpg";
      lock_wallpaper = wallpaper;

      mainFont = "Ttyp0";
      jpFont = "Unifont";
      nerdFont = "Hack Nerd Font";
      emojiFont = "Noto Color Emoji";
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
          disko.nixosModules.disko
          ./disk-config.nix
          {
              disko.devices.disk.main.device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_S4CJNZFN444131M";
          }
          nixos-hardware.nixosModules.lenovo-thinkpad-t430
          ./system/filesystems.nix
          ./system/configuration.nix
          ./system/hardware-configuration.nix
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
          nix-index-database.homeModules.nix-index
          nvf.homeManagerModules.default
          sops-nix.homeManagerModules.sops
          ./home-manager/home.nix
          ./home-manager/email.nix
        ];
        extraSpecialArgs = {
          inherit userSettings;
          inherit systemSettings;
          inherit self;
          inherit pkgs-unstable;
        };
      };
    };
  };
}
