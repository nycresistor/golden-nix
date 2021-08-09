let
  pkgs = import ./pkgs.nix;
  makeContainer = x: import x { inherit pkgs; };
in
with pkgs;
{
  containers = {
    unifi = makeContainer ./unifi.nix;

    torrouternix = makeContainer ./torrouter.nix;
    torclient = makeContainer ./torclient.nix;

    chaosclient = makeContainer ./chaosclient.nix;
  };
}
