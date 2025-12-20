{
  gitUsername = "Роман Васильченко";

  keyboardLayout = "us,ru";
  consoleKeyMap = "us";

  # Device type: "laptop" or "server"
  # Controls whether GUI/desktop modules are loaded
  deviceType = "laptop";

  # Enable Printing Support
  printEnable = false;

  # Enable work features (VPN, work email, GitLab SSH, career tracking)
  workEnable = false;

  # SSH key for agenix secrets decryption (use real file, not symlink)
  sshKeyPath = "/home/romanv/.ssh/id_personal_real";

  # App toggles (package + autostart)
  bitwarden = {
    enable = true;
    autostart = true;
  };
  brave = {
    enable = true;
    autostart = true;
  };
  joplin = {
    enable = true;
    autostart = true;
  };
  solaar = {
    enable = true;
    autostart = true;
  };
  telegram = {
    enable = true;
    autostart = true;
  };
  thunderbird = {
    enable = true;
    autostart = true;
  };
  zapzap = {
    enable = true;
    autostart = true;
  };
  zoom = {
    enable = true;
    autostart = true;
  };
}
