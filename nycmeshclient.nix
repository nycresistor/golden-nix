{ pkgs
}:
{
  autoStart = true;
  macvlans = [ "nycmesh" ];
  nixpkgs = pkgs.path;
  config = { ... }: {
    nixpkgs.pkgs = pkgs;
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks.mv-nycmesh = {
        matchConfig = {
          Name = "mv-nycmesh";
        };
        DHCP = "yes";
      };
    };
  };
}
