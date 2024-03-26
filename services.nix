{
  systemd.services = {
    func_supa =
      let
        dir = "/home/supa/git/func_supa";
      in
      {
        enable = true;
        unitConfig = {
          After = "network.target";
        };
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 5;
          WorkingDirectory = dir;
          ExecStart = "${dir}/func_supa";
        };
        wantedBy = [ "multi-user.target" ];
      };
  };
}
