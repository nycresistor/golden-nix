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

    iptables-nftables-compat
  ];
  services.lldpd.enable = true;

  networking.firewall.package = pkgs.iptables-nftables-compat;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
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

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';

  services.resolved = {
    dnssec = "true";

    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google 1.0.0.1#cloudflare-dns.com 8.8.4.4#dns.google 2606:4700:4700::1111#cloudflare-dns.com 2001:4860:4860::8888#dns.google 2606:4700:4700::1001#cloudflare-dns.com  2001:4860:4860::8844#dns.google
      MulticastDNS=yes
      DNSOverTLS=yes
    '';

    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "8.8.8.8#dns.google"
      "1.0.0.1#cloudflare-dns.com"
      "8.8.4.4#dns.google"
      "2606:4700:4700::1111#cloudflare-dns.com"
      "2001:4860:4860::8888#dns.google"
      "2606:4700:4700::1001#cloudflare-dns.com"
      "2001:4860:4860::8844#dns.google"
    ];
  };
}
