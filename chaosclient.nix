{ pkgs
}:
let
  mv_nic = "chaosvpn";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { ... }: {
    imports = [ ./includes/client.nix ];
    nixpkgs.pkgs = pkgs;
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks."mv-${mv_nic}" = {
        matchConfig = {
          Name = "mv-${mv_nic}";
        };
        DHCP = "yes";
      };
    };
  };
}
