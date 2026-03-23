{
  ...
}:
{
  services = {
    fstrim.enable = true;

    dbus.implementation = "broker";

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;

        KexAlgorithms = [
          "mlkem768x25519-sha256"
          "sntrup761x25519-sha512@openssh.com"
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];
      };
      ports = [ 22 ];
    };

    smartd = {
      enable = true;
      autodetect = true;
    };
  };
}
