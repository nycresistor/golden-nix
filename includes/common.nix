{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lldpd
    htop
    dstat
  ];
  services.lldpd.enable = true;
}
