{ ... }:
(builtins.getFlake (builtins.toString ./.)).packages."${builtins.currentSystem}"

