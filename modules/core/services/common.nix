# Common services - available on all systems
{
  profile,
  ...
}:
{
  services = {
    # SSD optimization
    fstrim.enable = true;

    # SSH server
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;

        # Post-quantum key exchange algorithms for SSH server
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

    # SMART disk monitoring (disabled in VMs)
    smartd = {
      enable = if profile == "vm" then false else true;
      autodetect = true;
    };
  };
}
