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
      ../includes/common.nix
    ];

    users.users.unifi.group = "unifi";
    users.groups.unifi = { };

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;
      dataDir = "/mnt/unifidata";
    };

    services.openssh.enable = false;
    networking.firewall.enable = false;
  };
}
