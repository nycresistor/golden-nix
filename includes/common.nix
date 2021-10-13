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

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };
}
