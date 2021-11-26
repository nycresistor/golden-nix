{ ... }:
{
  users.extraUsers = {
    shammas = {
      isNormalUser = true;
      createHome = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIR85OQWCKZz8AofJcLO48UnvVlXZaKGlelYOx6WITP shammas@glap"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrAxJtkMUjVhFJ2o5UPXbQLn8Q92c3g4xuCjCBtNmnz shammas@bigtower"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGF99yGzL9/m2X8W1ea6gjifSY4s2dinLhUijuYbgfaX georg@DESKTOP-AIUJF2H"
      ];

    };
    mz = {
      isNormalUser = true;
      createHome = true;
      uid = 1011;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFR5kQ/J2ywKd2mOx1p2hJ1c8/7yLIB7vhQjxy4OpXWF mz@eaon"
      ];
    };
    micro = {
      isNormalUser = true;
      createHome = true;
      uid = 1012;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONeQ2ziY1Ly8tzou7da9dILBFSixNOl6kuPGNgbKI5U micro@moya"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOlUI4Bhg5PCfCsnTmF0IUo5HHMBUSUAyB+vG6iVstt"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCUnFlQaX/Dynl01PXqeAIM5ysFFxrXKH2A79A6/BDM"

      ];
    };
    leee = {
      isNormalUser = true;
      createHome = true;
      uid = 1013;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeqLNkVX0zY6jjD3I3mRdGu3RhZj627CQWWuPSXDgbK"
      ];
    };
  };
    djbeadle = {
      isNormalUser = true;
      createHome = true;
      uid = 1014;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAWBMdAWdkqpW/0SiModVY79tAfTq9CDoQpMXW2lescI"
      ];
    };
  };
}
