{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.networking.glorytun;
  pathOpts = { ... }: {
    options = {
      outboundInterfaceName = mkOption {
        example = "eth0";
        type = with types; str;
        description = '' '';
      };
      txRate = mkOption {
        default = 12500000;
        type = with types; int;
        description = '' '';
      };
      rxRate = mkOption {
        default = 12500000;
        type = with types; int;
        description = '' '';
      };
      backup = mkOption {
        default = false;
        type = with types; bool;
        description = '' '';
      };
      autoRate = mkOption {
        default = false;
        type = with types; bool;
        description = '' '';
      };
      beat = mkOption {
        default = null;
        type = with types; nullOr int;
        description = '' '';
      };
      lossLimit = mkOption {
        default = null;
        type = with types; nullOr int;
        description = '' '';
      };
    };
  };
  interfaceOpts = { ... }: {

    options = {
      keyFile = mkOption {
        example = "/private/wireguard_key";
        type = with types; nullOr str;
        default = null;
        description = '' '';
      };
      bindAddress = mkOption {
        default = "0.0.0.0";
        type = with types; str;
        description = '' '';
      };
      remoteAddress = mkOption {
        example = "8.8.8.8";
        type = with types; nullOr str;
        default = null;
        description = '' '';
      };
      remotePort = mkOption {
        default = null;
        type = with types; nullOr int;
        description = '' '';
      };
      bindPort = mkOption {
        default = null;
        type = with types; nullOr int;
        description = '' '';
      };
      autoRate = mkOption {
        default = false;
        type = with types; bool;
        description = '' '';
      };
      chacha = mkOption {
        default = false;
        type = with types; bool;
        description = '' '';
      };
      paths = mkOption {
        default = [ ];
        type = with types; listOf (submodule pathOpts);
        description = '' '';
      };
    };
  };

  generatePathUnit = { glorytunInterfaceName, glorytunInterfaceConfig, pathCfg }:
    let
      dev = glorytunInterfaceName;
      oif = pathCfg.outboundInterfaceName;
      serviceName = pathUnitServiceName dev oif;
      preScript = ''
        SRC=$(${pkgs.iproute2}/bin/ip route get oif "${oif}" "${glorytunInterfaceConfig.remoteAddress}" | ${pkgs.gawk}/bin/awk '/src/{getline;print $0}' RS=' ')
      '';
    in
    nameValuePair "glorytun-${dev}-path-${oif}" {
      description = "Glorytun Path - ${glorytunInterfaceName} - ${pathCfg.outboundInterfaceName}";
      requires = [ "glorytun-${glorytunInterfaceName}.service" ];
      after = [ "glorytun-${glorytunInterfaceName}.service" ];
      wantedBy = [ "multi-user.target" "glorytun-${glorytunInterfaceName}.service" ];
      environment.DEVICE = glorytunInterfaceName;
      path = with pkgs; [ iproute2 gawk cfg.package ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "300";
      };

      script =
        let
          targetState = if pathCfg.backup then "backup" else "up";
          setup = concatStringsSep " " (
            [ ''"${cfg.package}/bin/glorytun" path "$SRC" dev "${glorytunInterfaceName}" ${targetState} rate'' ]
            ++ optional pathCfg.autoRate ''auto''
            ++ [ ''rx ${builtins.toString pathCfg.rxRate} tx ${builtins.toString pathCfg.txRate}'' ]
            ++ optional (pathCfg.beat != null) ''beat ${builtins.toString pathCfg.beat}''
            ++ optional (pathCfg.lossLimit != null) ''losslimit ${pathCfg.lossLimit}''
          );
        in
        ''
          ${preScript}
          ${setup}
        '';

      postStop = ''
        ${preScript}
        "${cfg.package}/bin/glorytun" path "$SRC" dev "${glorytunInterfaceName}" down
      '';
    };

  generateInterfaceUnit = name: values:
    let
    in
    nameValuePair "glorytun-${name}" {
      description = "Glorytun Tunnel - ${name} ";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ iproute2 cfg.package ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
      };
      script =
        let
          bindStr = concatStringsSep " " (
            [ "${values.bindAddress}" ]
            ++ optional (values.bindPort != null) ''${bindPort}''
          );
          remoteStr = concatStringsSep " " ([ ]
            ++ optional (values.remoteAddress != null) ''to ${values.remoteAddress}''
            ++ optional (values.remotePort != null) ''${values.remotePort}'');
          setup = concatStringsSep " " (
            [ ''exec ${cfg.package}/bin/glorytun bind ${bindStr} ${remoteStr}'' ]
            ++ [ ''dev ${name} keyfile ${values.keyFile}'' ]
            ++ optional (values.chacha) "chacha"
          );
        in
        ''
          ${setup}
        '';
    };

in
{
  options.networking.glorytun = {
    enable = mkEnableOption "CHANGE";

    package = mkOption {
      type = types.package;
      default = pkgs.glorytun;
      defaultText = "pkgs.glorytun";
      description = "Set version of glorytun package to use.";
    };

    interfaces = mkOption {
      description = "Glorytun interfaces.";
      default = { };
      example = { };
      type = with types; attrsOf (submodule interfaceOpts);
    };
  };

  config = mkIf cfg.enable (
    let all_paths = flatten
      (mapAttrsToList
        (glorytunInterfaceName: glorytunInterfaceConfig:
          map (pathCfg: { inherit glorytunInterfaceName glorytunInterfaceConfig pathCfg; }) glorytunInterfaceConfig.paths
        )
        cfg.interfaces); in
    {
      environment.systemPackages = [ cfg.package ]; # if user should have the command available as well

      systemd.services =
        (mapAttrs' generateInterfaceUnit cfg.interfaces)
        // (listToAttrs (map generatePathUnit all_paths));

    }
  );

  meta.maintainers = with lib.maintainers; [ georgyo ];
}
