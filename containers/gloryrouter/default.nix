{ pkgs }:
{
  autoStart = true;
  macvlans = [ "enp3s0" "nycmesh" "linknyc" "enp0s29f7u1" "glory" ];
  nixpkgs = pkgs.path;

  allowedDevices = [
    { node = "/dev/net/tun"; modifier = "rwm"; }
  ];

  config = { ... }: {

    nixpkgs.pkgs = pkgs;
    imports = [
      ../../includes/common.nix
      ../../includes/client.nix
      ../../includes/users.nix
      ../../includes/glorytun.nix
      ./monitoring.nix
      ./nginx.nix
    ];

    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      authorizedKeysFiles = pkgs.lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.useNetworkd = true;
    networking.useHostResolvConf = false;

    programs.mosh.enable = true;

    services.miniupnpd = {
      enable = true;
      internalIPs = [ "mv-glory" ];
      externalInterface = "gtc-main";
    };

    networking.glorytun = {
      enable = true;

      interfaces = {
        gtc-main = {
          keyFile = "/root/glory.key";
          remoteAddress = "172.104.15.252";
          chacha = true;
          paths = [
            {
              outboundInterfaceName = "mv-enp3s0";
              autoRate = true;
            }
            {
              outboundInterfaceName = "mv-nycmesh";
              autoRate = true;
            }
            {
              outboundInterfaceName = "mv-linknyc";
              autoRate = true;
            }
            {
              outboundInterfaceName = "mv-enp0s29f7u1";
              autoRate = true;
              backup = true;
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
          #linkConfig = {
          #  RequiredForOnline = false;
          #};
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
            {
              routingPolicyRuleConfig = {
                To = inet;
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
        networks.mv-enp3s0 = tabledInterface "mv-enp3s0" "192.168.0.0/24" 51;
        networks.mv-nycmesh = tabledInterface "mv-nycmesh" "10.70.179.0/24" 52;
        networks.mv-linknyc = tabledInterface "mv-linknyc" "192.168.89.0/24" 53;
        networks.mv-enp0s29f7u1 = tabledInterface "mv-enp0s29f7u1" "192.168.1.0/24" 54;
        networks.mv-glory = {
          matchConfig = { Name = "mv-glory"; };
          address = [ "192.168.90.1/24" ];
          networkConfig = {
            DHCPServer = "yes";
            IPMasquerade = "yes";
          };

          dhcpServerConfig = {
            PoolOffset = 50;
            EmitDNS = "yes";
            DNS = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
          };
        };
        networks.gtc-main = {
          matchConfig = {
            Name = "gtc-main";
          };
          gateway = [ "192.168.91.1" ];
          dns = [ "8.8.8.8" "1.1.1.1" ];
          addresses = [
            {
              addressConfig = {
                Address = "192.168.91.2/30";
              };
            }
          ];

        };
      };
  };
}

