{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, extra-container, nixpkgs, flake-utils, sops-nix, ... }@inputs:

    let
      localOverlay = final: prev: {
        glorytun = final.callPackage ./packages/glorytun { };
        mlvpn = final.callPackage ./packages/mlvpn { };
        inherit inputs;
      };

      nixpkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [
          sops-nix.overlay
          localOverlay
        ];
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "unifi-controller"
            "ookla-speedtest"
          ];
        };
      };


    in
    flake-utils.lib.eachSystem extra-container.lib.supportedSystems (system: {
      overlay = localOverlay;


      devShells.default = with (nixpkgsFor system); mkShell {
        nativeBuildInputs = [
          sops-import-keys-hook
        ];

        sopsPGPKeyDirs = [
          "./keys/hosts"
          "./keys/users"
        ];
      };

      packages.default = extra-container.lib.buildContainers {
        # The system of the container host
        inherit system nixpkgs;

        config.containers =
          let
            pkgs = nixpkgsFor system;
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
