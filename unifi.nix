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
  config = { pkgs, lib, ... }: {
    nixpkgs.config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unifi-controller"
      ];
    };

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;
      dataDir = "/mnt/unifidata";
    };
    networking.firewall.enable = false;
  };
}
