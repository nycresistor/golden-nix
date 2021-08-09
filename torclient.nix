{ pkgs
}:
{
  macvlans = [ "tornet" ];
  nixpkgs = pkgs.path;
  config = { pkgs, lib, ... }: {
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks.mv-tornet = {
        matchConfig = {
          Name = "mv-tornet";
        };
        DHCP = "yes";
      };
    };
  };
}
