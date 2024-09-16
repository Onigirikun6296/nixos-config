{pkgs, ...}: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.hplipWithPlugin];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.hplipWithPlugin];
  };

  environment.systemPackages = with pkgs; [
    hplip
  ];
}
