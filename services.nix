{ lib, pkgs, ... }:

{
  systemd.services = {
    # func_supa =
    #   let
    #     dir = "/home/supa/git/func_supa";
    #     dependencies = [ pkgs.yt-dlp pkgs.zbar ];
    #   in
    #   {
    #     enable = true;
    #     unitConfig = {
    #       After = "network.target";
    #     };
    #     serviceConfig = {
    #       Type = "simple";
    #       User = "supa";
    #       Restart = "always";
    #       RestartSec = 5;
    #       WorkingDirectory = dir;
    #       ExecStart = "${dir}/func_supa";
    #       Environment = "PATH=${lib.makeBinPath dependencies}";
    #     };
    #     wantedBy = [ "multi-user.target" ];
    #   };
  };
}
