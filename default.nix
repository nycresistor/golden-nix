let
  pkgs = import ./pkgs.nix { };
  makeContainer = x: import x { inherit pkgs; };
  buildContainerList = path:
    let content = builtins.readDir path; in
    builtins.listToAttrs (
      builtins.map
        (n:
          {
            name = pkgs.lib.removeSuffix ".nix" n;
            value = makeContainer (path + ("/" + n));
          })
        (builtins.filter (n: builtins.match ".*\\.nix" n != null || builtins.pathExists (builtins.path + ("/" + n + "/default.nix"))) (builtins.attrNames content))
    );
in
{
  containers = buildContainerList ./containers;
}
