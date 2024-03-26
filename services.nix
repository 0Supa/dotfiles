{
  systemd.services = {
    func_supa =
      let
        dir = "/home/supa/git/func_supa";
      in
      {
        enable = true;
        unitConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 5;
        };
        serviceConfig = {
          WorkingDirectory = dir;
          ExecStart = "${dir}/func_supa";
        };
        wantedBy = [ "multi-user.target" ];
      };
  };
}
