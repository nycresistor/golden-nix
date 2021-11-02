{ pkgs, lib, ... }:
{
  imports = [
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    lldpd
    htop
    dstat
    gnupg
    age
    python3

    ookla-speedtest
    fast-cli
    tcpdump
    mtr
    nmap
    curl
    wget
    whois
  ];
  services.lldpd.enable = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = lib.mkDefault true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    authorizedKeysFiles = pkgs.lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  };

  programs.mosh.enable = true;

}
