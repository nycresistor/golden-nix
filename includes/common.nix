{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lldpd
    htop
    dstat
    gnupg
    age
  ];
  services.lldpd.enable = true;
}
