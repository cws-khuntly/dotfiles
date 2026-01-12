# My dotfiles

These are my dotfiles. They're here for everyone to steal if desired, I don't mind.

I was using dotbot (https://github.com/anishathalye/dotbot)  for the installation, but that broke in environments where I couldn't install dotbot. So I wrote my own installation script and based the input file off what dotbot had if I recall correctly.

To get started with defaults:

```
$ git clone https://github.com/cws-khuntly/dotfiles.git ${HOME}/.dotfiles;

$ ANSIBLE_CONFIG="${HOME}/.dotfiles/ansible/ansible.cfg" ansible-playbook --connection=local "${HOME}/.dotfiles/ansible/site.yml";
```

To set up a vault for default configuration (this sets up SSH/GPG passphrases, email, name, etc), create a vault (this one uses a text file for a password, use @prompt to be prompted for a password):

```
$ mkdir -pv ${HOME}/workspace/ansible/vault;

$ ansible-vault edit --vault-id dotfiles@${HOME}/workspace/ansible/vault/ansible.txt ${HOME}/workspace/ansible/vault/dotfiles.yml
```

What I usually do is set up a default values to override the ones provided in `group_vars` and a separate `dotfiles.yml` vault file containing passwords/passphrases and any other user-specific information.

I don't make changes every day but it is fairly active. If you have any questions or anything like that create an issue or toss me an email or whatever and I'll help where I can!
