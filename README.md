# A very basic start with NixOS & flakes on WSL

I love the idea of a declarative OS, so I had to give it a go.

It's nowhere near where I want it to be, but it's kind of heading in the right direction.

Several more things to do, including at least:

- [ ] get my proper emacs config over
- [ ] set up some nix shell goodness for various dev envs (cloud tools, rust, C++, etc etc)
- [X] make sure it works on another machine (write up how to bootstrap it)
- [ ] get the tide prompt config bootstrapping working

## Very quick notes

### Install NixOS WSL

[Follow these instructions](https://nix-community.github.io/NixOS-WSL/install.html), which boil down to:

 - [Download this](https://github.com/nix-community/NixOS-WSL/releases/download/2405.5.4/nixos-wsl.tar.gz)
 - Run `wsl --import NixOS %USERPROFILE%\NixOS\ nixos-wsl.tar.gz --version 2`
 - Run `wsl -d NixOS`

### Clone this git repo

```
nix-shell -p git
git clone https://github.com/kneilb/nixos-dotfiles.git
mv nixos-dotfiles .nixos
```

### Apply the flake

```
sudo nixos-rebuild switch --flake ~/.nixos
```

If you get errors about not providing attributes, it might just be that the WSL hostname isn't one of the ones I'm expecting.
You can fix this with `sudo hostname`.
