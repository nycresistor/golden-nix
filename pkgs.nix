let
  nixpkgs_rev = "6ef4f522d63f22b40004319778761040d3197390";
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs_rev}.tar.gz";
  };
in
import nixpkgs {
  config = {
    allowUnfreePredicate = pkg: with pkg;[
      unifi-controller
    ];
  };
  overlays = [ ];
}
