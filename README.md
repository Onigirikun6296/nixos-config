# My Nix configuration
## Installation

First run `nixos-generate-config --root /tmp/config --no-filesystems` and place the flake inside `/tmp/config/etc/nixos`. Do not overwrite the generated `hardware-configuration.nix` in that folder and be sure to edit the `flake.nix` file or any other required module such as email.

Afterwards run the installation according to the following syntax:
```console
sudo nix run 'github:nix-community/disko#disko-install' -- --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>
```
For example:
```console
sudo nix run 'github:nix-community/disko#disko-install' -- --flake '/tmp/config/etc/nixos#Orion' --disk main /dev/sda
```
