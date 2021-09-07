{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # speedtest-cli
    ookla-speedtest
    fast-cli
    tcpdump
    mtr
    nmap
    curl
    wget
  ];

}
