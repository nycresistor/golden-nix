{ pkgs
}:
{
  autoStart = true;
  macvlans = [ "tornet" "enp2s0" ];
  nixpkgs = pkgs.path;
  config = { pkgs, lib, ... }: {

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    environment.systemPackages = with pkgs; [ tcpdump ];
    services.dnsmasq = {
      enable = true;
      extraConfig = ''
        no-hosts
        no-resolv
        no-poll
        no-negcache
        bogus-priv

        interface=mv-tornet
        bind-interfaces


        all-servers
        server=127.0.0.1#9053
        server=/onion/127.0.0.1#9053
        server=/exit/127.0.0.1#9053

        domain=tor.nycr.us
        domain=tor.nycr.us,192.168.70.0/24,local
        synth-domain=tor.nycr.us,192.168.70.0/24,unused-
        dhcp-fqdn

        dhcp-range=192.168.70.100,192.168.70.200,255.255.255.0,12h
        dhcp-option=6,192.168.70.1
      '';
    };

    services.tor = {
      enable = true;
      settings = {
        DNSPort = 9053;
        AutomapHostsOnResolve = true;
        AutomapHostsSuffixes = [ ".onion" ".exit" ];
        VirtualAddrNetworkIPv4 = "10.192.0.0/11";
        VirtualAddrNetworkIPv6 = "[FC00::]/7";
        TransPort = [
          {
            addr = "0.0.0.0";
            port = 9040;
            flags = [ "PreferIPv6Automap" "IPv6Traffic" "PreferIPv6" "IsolateClientAddr" "IsolateClientProtocol" "IsolateDestAddr" "IsolateDestPort" ];
          }
          {
            addr = "[::]";
            port = 9040;
            flags = [ "PreferIPv6Automap" "IPv6Traffic" "PreferIPv6" "IsolateClientAddr" "IsolateClientProtocol" "IsolateDestAddr" "IsolateDestPort" ];
          }
        ];
        ControlPort = 9051;
        CookieAuthentication = true;
        SocksPort = [ "9050" ];
        SocksPolicy = [ "accept 192.168.0.0/16" "accept 127.0.0.0/8" "reject *" ];
      };
    };
    networking.useHostResolvConf = false;
    networking.firewall = {
      enable = true;
      allowPing = true;
      extraCommands = ''
        #iptables -t nat -A PREROUTING -i mv-tornet -p udp -m udp --dport 53 -j REDIRECT --to-ports 53
        #iptables -t nat -A PREROUTING -i mv-tornet -p tcp -j REDIRECT --to-ports 9040
        iptables -t nat -A PREROUTING -i mv-tornet -p udp --dport 53 -j REDIRECT --to-ports 53
        iptables -t nat -A PREROUTING -i mv-tornet -p udp --dport 5353 -j REDIRECT --to-ports 53
        iptables -t nat -A PREROUTING -i mv-tornet -p tcp --syn -j REDIRECT --to-ports 9040

        iptables -N tor-fw
        iptables -N reject
        iptables -A INPUT -i mv-tornet -j tor-fw
        iptables -A tor-fw -p udp -m udp --dport 67:68 -j ACCEPT
        iptables -A tor-fw -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -A tor-fw -p udp -m udp --dport 53 -m conntrack --ctorigdstport 53 -j ACCEPT
        iptables -A tor-fw -p tcp -m tcp --dport 9040 -j ACCEPT
        iptables -A tor-fw -g reject

        iptables -A reject -m addrtype --src-type BROADCAST -j DROP
        iptables -A reject -s 224.0.0.0/4 -j DROP
        iptables -A reject -p igmp -j DROP
        iptables -A reject -p tcp -j REJECT --reject-with tcp-reset
        iptables -A reject -p udp -j REJECT --reject-with icmp-port-unreachable
        iptables -A reject -p icmp -j REJECT --reject-with icmp-host-unreachable
        iptables -A reject -j REJECT --reject-with icmp-host-prohibited

      '';
    };
    systemd.network = {
      enable = true;
      networks.mv-enp2s0 = {
        matchConfig = {
          Name = "mv-enp2s0";
        };
        DHCP = "yes";
      };
      networks.mv-tornet = {
        matchConfig = {
          Name = "mv-tornet";
        };
        address = [ "192.168.70.1/24" ];
      };
    };
  };
}
