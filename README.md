# My dotfiles

These are my dotfiles. They're here for everyone to steal if desired, I don't mind.

I was using dotbot (https://github.com/anishathalye/dotbot)  for the installation, but that broke in environments where I couldn't install dotbot. So I wrote my own installation script and based the input file off what dotbot had if I recall correctly.

I made an Ansible playbook
```
ansible-playbook -i workspace/dotfiles/ansible/inventory/hosts.yml workspace/dotfiles/ansible/site.yml
```

I don't make changes every day but it is fairly active. If you have any questions or anything like that create an issue or toss me an email or whatever and I'll help where I can!
