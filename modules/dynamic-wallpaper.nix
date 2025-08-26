{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "elijah";
in {
  systemd.user.services.dynamic-wallpaper = {
    unitConfig = {
      Description = "Rotate GNOME wallpaper";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash /home/${user}/nix-config/modules/dynamic-wall.sh";
      Restart = "always";
      RestartSec = "5s";
      Environment = [
        "PATH=${lib.makeBinPath [
          pkgs.glib.bin
          pkgs.gsettings-desktop-schemas
          pkgs.dconf
          pkgs.findutils
          pkgs.gnused
          pkgs.coreutils
        ]}"
      ];
    };

    wantedBy = [ "graphical-session.target" ];
  };
}

