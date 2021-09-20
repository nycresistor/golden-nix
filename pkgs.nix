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
}

