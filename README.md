# A very basic start with NixOS & flakes on WSL

I love the idea of a declarative OS, so I had to give it a go.

It's nowhere near where I want it to be, but it's kind of heading in the right direction.

Several more things to do, including at least:

- [ ] get my proper emacs config over
- [ ] set up some nix shell goodness for various dev envs (cloud tools, rust, C++, etc etc)
- [ ] make sure it works on another machine (write up how to bootstrap it)

## Very quick notes

Install NixOS WSL [like this](https://nix-community.github.io/NixOS-WSL/install.html)

Install git

Clone this git repo (following assumes into `~/.nixos`)

Apply the flake

```
sudo nixos-rebuild switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake ~/.nixos
```

Assuming it works, the new config will have the experimental stuff enabled, so there's no need to keep passing those options.
i.e. you can just do this:

```
sudo nixos-rebuild switch flakes --flake ~/.nixos
```
