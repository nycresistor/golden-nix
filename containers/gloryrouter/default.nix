{ pkgs }:
{
  autoStart = true;
  macvlans = [ "enp2s0" "nycmesh" "linknyc" ];
  nixpkgs = pkgs.path;

  allowedDevices = [
    { node = "/dev/net/tun"; modifier = "rwm"; }
  ];

  config = { ... }: {

    nixpkgs.pkgs = pkgs;
    imports = [
      ../../includes/common.nix
      ../../includes/client.nix
      ../../includes/glorytun.nix
    ];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.useNetworkd = true;
    networking.useHostResolvConf = false;

    environment.systemPackages = [ pkgs.glorytun ];

    networking.glorytun = {
      enable = true;

      interfaces = {
        gtc-main = {
          keyFile = "/root/glory.key";
          remoteAddress = "172.104.15.252";
          chacha = true;
          paths = [
            {
              outboundInterfaceName = "enp2s0";
              autoRate = true;
            }
            {
              outboundInterfaceName = "nycmesh";
              autoRate = true;
            }
            {
              outboundInterfaceName = "linknyc";
              autoRate = true;
            }
          ];
        };

      };

    };

    systemd.network =
      let
        tabledInterface = iface: inet: table: {
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
            {
              routingPolicyRuleConfig = {
                From = inet;
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
        networks.mv-enp2s0 = tabledInterface "mv-enp2s0" "192.168.0.0/24" 51;
        networks.mv-nycmesh = tabledInterface "mv-nycmesh" "10.255.255.0/24" 52; # Actual subnet unknown
        networks.mv-linknyc = tabledInterface "mv-linknyc" "192.168.89.0/24" 53;
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

