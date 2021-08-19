let
  sources = import ./nix/sources.nix;
  getName = x:
    let
      parse = drv: (builtins.parseDrvName drv).name;
    in
    if builtins.isString x
    then parse x
    else x.pname or (parse x.name);

  pkgs = import sources.nixpkgs {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (getName pkg) [
        "unifi-controller"
      ];
    };
  };
  makeContainer = x: import x { inherit pkgs; };
in
with pkgs;
{

  containers = {
    unifi = makeContainer ./unifi.nix;

    torrouternix = makeContainer ./torrouter.nix;
    torclient = makeContainer ./torclient.nix;

    chaosclient = makeContainer ./chaosclient.nix;

    # nycmeshclient = makeContainer ./nycmeshclient.nix;
  };
}
