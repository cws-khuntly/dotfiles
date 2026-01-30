# Vault placeholder

This folder is used to store vaulted files, and the dotfiles role looks here for a file named "dotfiles.yml". 

The file does not need to be vaulted, but it does contain sensitive information so it probably should be 

The `.gitignore` housed within this directory ignores all `*.yml` files. If you want to store your file here in Git, either change the file extension to `.yaml` or modify the provided `.gitignore`.

Here's a complete example:

```
---
secrets:
  bitwarden:
    BW_ACCESS_TOKEN: ""

  google:
    GCP_SERVICE_ACCOUNT: ""

bitwarden:
  vault_url: ""

gcp:
  projects:
    project_id: ""

user_account:
  name: ""
  email: ""

  ssh:
    enabled: < true | false >
    fetch_keys: < true | false >
    key_source: ""
    key_id: ""
    generate_keys: < true | false >
    passphrase: ""
    key_type: ""

  gpg:
    enabled: < true | false >
    fetch_keys: < true | false >
    key_source: ""
    key_id: ""
    generate_keys: < true | false >
    key_type: ""
    key_length: < length >
    subkey_type: ""
    subkey_length: < length >
    expiry: ""
    passphrase: ""

  git:
    enabled: < true | false >
    fetch_keys: < true | false >
    key_source: ""
    key_id: ""
    signing_key: ""

  smtp:
    accounts:
      - name: ""
        enabled: < true | false >
        account_name: ""
        username: ""
        password: ""
        hostname: ""
        port: < port >
        use_tls: < true | false >

  systemd:
    enabled: < true | false >
    services:
      - name: "service.<service | target | timer >"
```

Thank you!