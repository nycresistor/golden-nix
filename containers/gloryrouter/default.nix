{ pkgs }:
{
  autoStart = true;
  macvlans = [ "enp2s0" "nycmesh" "linknyc" ];
  nixpkgs = pkgs.path;

  config = { ... }: {

    nixpkgs.pkgs = pkgs;
    imports = [
      ../../includes/common.nix
      ../../includes/client.nix
    ];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.useNetworkd = true;
    networking.useHostResolvConf = false;

    systemd.services."glorytun@gtc-main" = {

      description = "A bridge between Matrix and Discord.";

      wantedBy = [ "network-online.target" ];


      serviceConfig =
        let
          ExecPost = pkgs.writeScript "glorytun-post.sh" ''
            DEV=$1
            getSourceIP() {
              ip route get oif "$1" 172.104.15.252
            }
            for i in mv-enp2s0 mv-nycmesh mv-linknyc; do 
              SRC=$(getSourceIP $i)
              ${pkgs.glorytun}/bin/glorytun path up "$SRC" dev "$DEV" rate rx 12500000 tx 12500000
            done
            exit 0
          '';
        in
        {
          Type = "simple";
          Restart = "always";
          RestartSec = 600;

          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          CapabilityBoundingSet = "CAP_NET_ADMIN";

          PrivateTmp = true;
          ExecStart = ''
            ${pkgs.glorytun}/bin/glorytun bind 0.0.0.0 to 172.104.15.252 dev %i keyfile /root/glory.key chacha
          '';
          postStart = ''
            "${ExecPost}" %s
          '';

        };

    };

    systemd.network =
      let
        tabledInterface = iface: table: {
          matchConfig = {
            Name = iface;
          };
          linkConfig = {
            RequiredForOnline = false;
          };
          DHCP = "yes";
          routingPolicyRules = [
            {
              routingPolicyRuleConfig = {
                OutgoingInterface = iface;
                Table = table;
              };
            }
          ];
          dhcpV4Config = {
            RouteTable = table;
          };
          ipv6AcceptRAConfig = {
            RouteTable = table;
          };
        };
      in
      {
        enable = true;
        networks.mv-enp2s0 = tabledInterface "mv-enp2s0" 51;
        networks.mv-nycmesh = tabledInterface "mv-nycmesh" 52;
        networks.mv-linknyc = tabledInterface "mv-linknyc" 53;
        networks.gtc-main = {
          matchConfig = {
            Name = "gtc-main";
          };
          gateway = [ "192.168.91.1" ];
          dns = [ "8.8.8.8" "1.1.1.1" ];
          addresses = [
            {
              addressConfig = {
                Address = "192.168.91.2";
                Peer = "192.168.91.1";
              };
            }
          ];
        };
      };
  };
}

