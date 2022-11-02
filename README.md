# Golden NIX

Configurations for networking containers running on golden, a server running in the NYC Resistor hackerspace.

##
How to build

```
nix build
```

## How to update dependencies

```
nix flake update --commit-lock-file
# Don't forget to git push if changes are good
```

## How to apply changes
```
nix run . -- create -s -u
```


## Why Nix

Our use cases could have been handled by docker, but with docker it is extreamly difficult to reproduce a build.  
