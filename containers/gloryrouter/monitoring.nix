{ config, pkgs, lib, ... }:
{

  services.munin-cron = {
    enable = true;
    hosts = ''
      [${config.networking.hostName}]
      address localhost
    '';
  };

  services.munin-node = {
    enable = true;
  };

}
