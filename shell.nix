let
  sources = import ./nix/sources.nix;
  pkgs = import ./pkgs.nix { inherit sources; };
in
with pkgs;
mkShell {
  nativeBuildInputs = [ extra-container nixos-container niv ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    export LOCALE_ARCHIVE_2_27=${pkgs.glibcLocales}/lib/locale/locale-archive
  '';
}
