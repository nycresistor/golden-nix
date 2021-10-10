# shell.nix
{ pkgs ? import ../../pkgs.nix { }}:
with pkgs;
mkShell {
  # imports all files ending in .asc/.gpg
  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  nativeBuildInputs = [
    sops-nix.sops-import-keys-hook
  ];
}
