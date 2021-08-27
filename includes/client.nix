{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    speedtest-cli
    ookla-speedtest
    tcpdump
    mtr
    nmap
    curl
    wget
  ];

}
