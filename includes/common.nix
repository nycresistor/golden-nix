{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ lldpd ];
  services.lldpd.enable = true;
}
