let
  sources = import ./nix/sources.nix;
  pkgs = import ./pkgs.nix { inherit sources; };
  extra-container = pkgs.callPackage sources.extra-container { };
  niv = import sources.niv { inherit sources pkgs; };
in
with pkgs;
mkShell {
  nativeBuildInputs = [ extra-container nixos-container niv.niv ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    export LOCALE_ARCHIVE_2_27=${pkgs.glibcLocales}/lib/locale/locale-archive
  '';
}
