{ pkgs
}:
let
  mv_nic = "enp2s0";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { config, ... }: {
    imports = [
      ../../includes/common.nix
      ../../includes/client.nix
      "${pkgs.niv_sources.sops-nix}/modules/sops"
      ./mastodon-bot.nix
    ];
    sops = {
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      defaultSopsFile = ./secrets.yaml;
      secrets = {
        mastodon-bot-config = {
          mode = "0440";
          owner = config.users.users.mastodon-bot.name;
          group = config.users.users.mastodon-bot.group;
        };
      };
    };

    services.mastodon-bot = {
      enable = true;
      configFile = config.sops.secrets.mastodon-bot-config.path;
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
