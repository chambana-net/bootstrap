users:
  root:
    home: /root
    ssh_auth_file:
      - {{ SSH_KEY }}

systemd-timesyncd:
  timeservers:
    - 0.debian.pool.ntp.org
    - 1.debian.pool.ntp.org
    - 2.debian.pool.ntp.org
    - 3.debian.pool.ntp.org

msmtp:
  lookup:
    settings:
      host: {{ EMAIL_SERVER }}
      port: 587
      user: {{ EMAIL_USER }}
      password: {{ EMAIL_PASSWORD }}

sshd_config:
  Port: 22
  Protocol: 2
  HostKey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_ed25519_key
  PasswordAuthentication: no
  ChallengeResponseAuthentication: no
  PubkeyAuthentication: yes
  PermitRootLogin: without-password
  AllowUsers: root
  Banner: /etc/issue.net
  KexAlgorithms: curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
  Ciphers: chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
  MACs: hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
