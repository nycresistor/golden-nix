{ ... }:
{
  users.extraUsers.shammas = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIR85OQWCKZz8AofJcLO48UnvVlXZaKGlelYOx6WITP shammas@glap"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrAxJtkMUjVhFJ2o5UPXbQLn8Q92c3g4xuCjCBtNmnz shammas@bigtower"
    ];

  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };

}
