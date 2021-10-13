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
      };
  };
}

