_: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/aed0a0d5-d478-4dc3-abb5-29d32bf65836";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A91C-33B4";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    "/mnt/Storage" = {
      device = "/dev/disk/by-uuid/fbd9e9f1-7c2c-4a71-827a-7062090b6df9";
      fsType = "ext4";
      options = [
        "users"
        "nofail"
        "exec"
      ];
    };

    "/mnt/hydrus" = {
      device = "/dev/disk/by-uuid/dfc2a709-d319-4bf6-bba3-fb1986540fff";
      fsType = "ext4";
      options = [
        "users"
        "nofail"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/a4a89793-3b33-4b3f-9a2b-255e822129b3";
      options = [
        "defaults"
        "nofail"
      ];
    }
  ];
}
