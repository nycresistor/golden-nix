let
  sources = import ./nix/sources.nix;
  pkgs = import ./pkgs.nix { inherit sources; };
  makeContainer = x: import x { inherit pkgs; };
in
{

  containers = {
    unifi = makeContainer ./unifi.nix;

    torrouternix = makeContainer ./torrouter.nix;
    torclient = makeContainer ./torclient.nix;

    coreclient = makeContainer ./coreclient.nix;
    chaosclient = makeContainer ./chaosclient.nix;

    linknycclient = makeContainer ./linknycclient.nix;

    nycmeshclient = makeContainer ./nycmeshclient.nix;
  };
}
