{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    extra-container.url = "github:erikarvstedt/extra-container";
    extra-container.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, extra-container, nixpkgs, ... }@inputs:

    let
      localOverlay = final: prev: {
        glorytun = final.callPackage ./packages/glorytun { };
        mlvpn = final.callPackage ./packages/mlvpn { };
        sops-nix = final.callPackage inputs.sops-nix { };
        sops-nix-dir = inputs.sops-nix;
 };


     in extra-container.inputs.flake-utils.lib.eachSystem extra-container.lib.supportedSystems (system: {
      overlay = localOverlay;

      packages.default = extra-container.lib.buildContainers {
        # The system of the container host
        inherit system nixpkgs;

        config.containers =
          let
            getName = x:
              let
                parse = drv: (builtins.parseDrvName drv).name;
              in
              if builtins.isString x
              then parse x
              else x.pname or (parse x.name);
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                localOverlay
              ];
              config = {
                allowUnfreePredicate = pkg: builtins.elem (getName pkg) [
                  "unifi-controller"
                  "ookla-speedtest"
                ];
              };
            };
            makeContainer = x: import x { inherit pkgs; };
            buildContainerList = path:
              let content = builtins.readDir path; in
              builtins.listToAttrs (
                builtins.map
                  (n:
                    {
                      name = nixpkgs.lib.removeSuffix ".nix" n;
                      value = makeContainer (path + ("/" + n));
                    })
                  (builtins.filter (n: builtins.match ".*\\.nix" n != null || builtins.pathExists (path + ("/" + n + "/default.nix"))) (builtins.attrNames content))
              );
          in
          buildContainerList ./containers;

      };
    });
}
