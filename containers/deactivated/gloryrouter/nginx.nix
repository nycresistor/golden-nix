{ config, pkgs, lib, ... }:
{

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "default" = {
        default = true;
        root = "/var/www";
      };

    };
  };

}
