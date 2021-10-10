{ pkgs
}:
let
  mv_nic = "enp2s0";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { ... }: {
    imports = [
      ../../includes/common.nix
      ../../includes/client.nix
      "${pkgs.niv_sources.sops-nix}/modules/sops"
    ];
    sops = {
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      defaultSopsFile = ./secrets.yaml;
      secrets = {
        mastadon-bot-config = {};
      };
    };



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
