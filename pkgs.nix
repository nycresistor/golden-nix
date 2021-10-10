{ sources ? import ./nix/sources.nix }:
let
  getName = x:
    let
      parse = drv: (builtins.parseDrvName drv).name;
    in
    if builtins.isString x
    then parse x
    else x.pname or (parse x.name);
in
import sources.nixpkgs {
  config = {
    allowUnfreePredicate = pkg: builtins.elem (getName pkg) [
      "unifi-controller"
      "ookla-speedtest"
    ];
  };
  overlays = [
    (self: super: {
      extra-container = self.callPackage sources.extra-container { };
      # niv = (import sources.niv { inherit sources; pkgs = self; }).niv;
      sops-nix = self.callPackage sources.sops-nix { };
      niv_sources = sources;
    })
  ];
}

