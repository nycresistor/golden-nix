{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.mastodon-bot;
in
{
  options.services.mastodon-bot = {
    enable = mkEnableOption "mastodon-bot";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/mastodon-bot";
      description = ''
        The directory where mastodon-bot stores its data files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "mastodon-bot";
      description = ''
        User account under which mastodon-bot runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "mastodon-bot";
      description = ''
        Group under which mastodon-bot runs.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.mastodon-bot;
      defaultText = literalExpression "pkgs.mastodon-bot";
      description = ''
        The mastodon-bot package to use.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
      '';
    };

    authConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
      '';
    };
  };

  config = mkIf cfg.enable {


    users.groups = mkIf (cfg.group == "mastodon-bot") {
      mastodon-bot = { };
    };

    users.users = mkIf (cfg.user == "mastodon-bot") {
      mastodon-bot = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        description = "mastodon-bot Daemon user";
        isSystemUser = true;
      };
    };

    systemd = {
      services.mastodon-bot = {
        description = "A bridge between Matrix and Discord.";

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        environment = {
          MASTODON_BOT_CONFIG = cfg.configFile;
          MASTODON_BOT_CREDENTIALS = cfg.authConfigFile;
        };


        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Type = "simple";
          Restart = "always";
          RestartSec = 600;

          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;

          DynamicUser = true;
          PrivateTmp = true;
          WorkingDirectory = cfg.dataDir;
          StateDirectory = cfg.dataDir;
          UMask = 0027;

          ExecStart = ''
            ${cfg.package}/bin/mastodon-bot
          '';
        };
      };
      tmpfiles.rules = [ "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -" ];
    };

  };
}
