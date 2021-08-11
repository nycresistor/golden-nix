let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  extra-container = pkgs.callPackage sources.extra-container { };
in
with pkgs;
mkShell {
  nativeBuildInputs = [ extra-container nixos-container ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    export LOCALE_ARCHIVE_2_27=${pkgs.glibcLocales}/lib/locale/locale-archive
  '';
}
