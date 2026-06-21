# My Nix configuration
## Installation

First run `nixos-generate-config --root /tmp/config --no-filesystems` and place the flake inside `/tmp/config/etc/nixos`. Do not overwrite the generated `hardware-configuration.nix` in that folder and be sure to edit the `flake.nix` file or any other required module such as email or disk-config.

Afterwards run the installation according to the following commands (example for machine #Pegasus):
```console
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/config/etc/nixos/disk-config.nix
sudo nixos-install --flake /tmp/config/etc/nixos#Pegasus

```
