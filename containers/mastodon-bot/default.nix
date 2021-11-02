{ pkgs
}:
let
  mv_nic = "enp3s0";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { config, ... }: {
    imports = [
      ../../includes/common.nix
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
      authConfigFile = config.sops.secrets.mastodon-bot-config.path;
      configFile = pkgs.writeText "mastodon-bot-config" ''
        {
          :transform [{
            :source {
              :source-type :rss
              :feeds [
                ["NYC Resistor Blog" "https://www.nycresistor.com/feed/"]
              ]
            }
            :target {
              :target-type :mastodon
              :append-screen-name? false
              :signature "#rssbot"
            }
            :resolve-urls? true
            :replacements nil
          }]
        }
      '';
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
