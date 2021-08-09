{ pkgs
}:
{
  macvlans = [ "chaosvpn" ];
  nixpkgs = pkgs.path;
  config = { pkgs, lib, ... }: {
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks.mv-chaosvpn = {
        matchConfig = {
          Name = "mv-chaosvpn";
        };
        DHCP = "yes";
      };
    };
  };
}
