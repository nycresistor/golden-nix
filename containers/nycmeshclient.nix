{ pkgs
}:
let
  mv_nic = "nycmesh";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { ... }: {
    imports = [
      ../includes/common.nix
    ];
    nixpkgs.pkgs = pkgs;
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks."mv-${mv_nic}" = {
        matchConfig = {
          Name = "mv-${mv_nic}";
        };
        linkConfig = {
          RequiredForOnline = false;
          ActivationPolicy = "always-up";
        };
        DHCP = "yes";
      };
    };
  };
}
