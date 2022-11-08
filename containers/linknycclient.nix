{ pkgs
}:
let
  mv_nic = "linknyc";
in
{
  autoStart = true;
  macvlans = [ mv_nic ];
  nixpkgs = pkgs.path;
  config = { ... }: {
    imports = [
      ../includes/common.nix
    ];
    nixpkgs.pkgs = pkgs;
    networking.firewall.enable = false;
    networking.useHostResolvConf = false;
    systemd.network = {
      enable = true;
      networks."mv-${mv_nic}" = {
        matchConfig = {
          Name = "mv-${mv_nic}";
        };
        DHCP = "yes";
        dns = [
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
    };
  };
}
