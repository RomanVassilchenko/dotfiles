{
  gitUsername = "Роман Васильченко";

  keyboardLayout = "us,ru";
  consoleKeyMap = "us";

  # Device type: "laptop" or "server"
  # Controls whether GUI/desktop modules are loaded
  deviceType = "server";

  # Enable Printing Support
  printEnable = false;

  # Enable work features (VPN, work email, GitLab SSH, career tracking)
  workEnable = false;

  # SSH key for agenix secrets decryption
  # Servers use the system SSH host key since secrets are decrypted during system activation
  sshKeyPath = "/etc/ssh/ssh_host_ed25519_key";
}
