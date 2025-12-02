let
  # Public SSH keys for each host
  laptop-82sn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAcIlwANtn26rwkJfUfZKMSfGScbtKIUSBOR4iIl3EV XiaoXinPro Work";
  probook-450 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq roman.vassilchenko.work@gmail.com";
in
{
  # VPN password for OpenFortiVPN (Dahua Dima)
  "secrets/vpn-dahua-password.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # VPN host IP for OpenFortiVPN (Dahua Dima)
  "secrets/vpn-dahua-host.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # VPN trusted certificate for OpenFortiVPN (Dahua Dima)
  "secrets/vpn-dahua-cert.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN gateway
  "secrets/vpn-bereke-gateway.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN DNS servers
  "secrets/vpn-bereke-dns.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN DNS search domains
  "secrets/vpn-bereke-dns-search.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # Work email address
  "secrets/work-email.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # SSH: Internal host IP (home server)
  "secrets/ssh-host-home-ip.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # SSH: Internal host IP (aq server)
  "secrets/ssh-host-aq-ip.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # Bereke GitLab hostname
  "secrets/bereke-gitlab-hostname.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # SSH: Username for aq server
  "secrets/ssh-aq-username.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN username
  "secrets/vpn-bereke-username.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN password
  "secrets/vpn-bereke-password.age".publicKeys = [
    laptop-82sn
    probook-450
  ];

  # BerekeBank VPN TOTP secret
  "secrets/vpn-bereke-totp-secret.age".publicKeys = [
    laptop-82sn
    probook-450
  ];
}
