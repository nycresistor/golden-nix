{ pkgs
}:
{
  autoStart = true;
  bindMounts = {
    "/mnt/unifidata" = {
      isReadOnly = false;
      hostPath = "/var/lib/unifi/";
    };
  };
  nixpkgs = pkgs.path;
  config = { ... }: {

    nixpkgs.pkgs = pkgs;
    imports = [
      ./includes/common.nix
    ];

    users.users.unifi.group = "unifi";
    users.groups.unifi = {};

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;
      dataDir = "/mnt/unifidata";
    };
    networking.firewall.enable = false;
  };
}
