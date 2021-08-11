nix-shell shell.nix --run "$(cat - << EOF
  extra-container build .
EOF
)"
