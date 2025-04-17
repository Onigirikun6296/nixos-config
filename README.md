# My Nix configuration
## Installation

First run `nixos-generate-config --root /tmp/config --no-filesystems` and place the flake inside `/tmp/config/etc/nixos`. Do not overwrite the generated `hardware-configuration.nix` in that folder and be sure to edit the `flake.nix` file or any other required module such as email.

Afterwards run the installation according to the following syntax:
```console
sudo nix run 'github:nix-community/disko#disko-install' -- --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>
```
For example:
```console
sudo nix run --extra-experimental-features "nix-command flakes" 'github:nix-community/disko#disko-install' -- --flake '/tmp/config/etc/nixos#Pegasus' --disk main /dev/sda
```
This however requires a large amount of ram since it first downloads inside tmpfs nix store. One way of circumventing this is to set TMPDIR to a different drive or first run disko on `disk-config.nix` and then run `nix-install`:
```console
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/config/etc/nixos/disk-config.nix
sudo nixos-install --flake /tmp/config/etc/nixos#Pegasus
```
