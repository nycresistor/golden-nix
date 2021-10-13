{

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils, extra-container, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      getName = x:
        let
          parse = drv: (builtins.parseDrvName drv).name;
        in
        if builtins.isString x
        then parse x
        else x.pname or (parse x.name);
    in
    {
      overlay = final: prev: {
        glorytun = final.callPackage ./packages/glorytun { };
      };
    } // (flake-utils.lib.eachSystem supportedSystems (system:
      let pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (getName pkg) [
            "unifi-controller"
            "ookla-speedtest"
          ];
        };

        overlays = [
          extra-container.overlay
          sops-nix.overlay
          self.overlay
        ];

      }; in
      {

        packages = pkgs;
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [ extra-container nixos-container sops-import-keys-hook ];
          
          sopsPGPKeyDirs = [
            "./keys/hosts"
            "./keys/users"
          ];

          shellHook = ''
            export NIX_PATH="nixpkgs=${nixpkgs}"
            export LOCALE_ARCHIVE_2_27=${pkgs.glibcLocales}/lib/locale/locale-archive
          '';

        };

      }

    ));

}
