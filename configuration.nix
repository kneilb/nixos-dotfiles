# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:
let
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  stateVersion = "24.05";
in
{
  wsl.enable = true;
  wsl.defaultUser = "kneilb";
  wsl.interop.includePath = false; # Don't add Windows to the PATH

  system.stateVersion = "${stateVersion}"; # Did you read the comment?

  # NAB additions
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # For devenv caching
  nix.extraOptions = ''
    extra-substituters = https://nixpkgs-python.cachix.org https://devenv.cachix.org
    extra-trusted-public-keys = nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  users.mutableUsers = false;
  users.users.kneilb = {
    isNormalUser = true;
    home = "/home/kneilb";
    description = "Neil Burningham";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/io7FvIDPRI13WDU5KkfB3uFAidJRrnHvy9gw3ZHcnOl04F2iHEZxui/foNfvTGzc1jQwJ3+isAtegbBpgZEBCn7AxDNjsTt14ccpvdivcW4P0cYVkOehTxTlYHDHLy8rBbjixK9F0V/z/+atkQJd8dTPWIJxYq//NgiDD8PxacJhsR/TUhRfc2EywjGDt5stVTa9Vcfo+8KblMLGzTa7YknMDf4qGuG1njz+E45WcM8x9yVYOMWGcpFwaGTA2rAhJr+MW8IjDGsFao/emuijyFMKZEvrhQAnrpZmEXt3+PR7OJ4pXbOxo20AdFAjjo0fezOsA6nmiB5UpTR+JgnB" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = [
    # TODO: Do these via devenvs instead
    # pkgs.cmake
    # pkgs.gcc
    # pkgs.gnumake
    # pkgs.gdb
    # pkgs.python3
  ];

  programs = {
    fish.enable = true;
  };

  home-manager.users.kneilb = { lib, ... }: {
    home.stateVersion = "${stateVersion}"; # Did you read the comment?

    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.aspellWithDicts
          (dict : with dict; [ en ]))
      pkgs.devenv
      pkgs.dust
      pkgs.ffmpeg
      pkgs.grc
      pkgs.kubectl # Not in devenv, needed for tide prompt
      pkgs.mtr
      pkgs.ncdu
      (pkgs.nerdfonts.override { fonts = ["FiraCode" "FiraMono" "Hack" "Meslo"]; })
      pkgs.unzip
      pkgs.wget
      pkgs.yq
    ];

    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.fd.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.ripgrep.enable = true;
    programs.tmux.enable = true;

    programs.emacs = {
      enable = true;
      package = (pkgs.emacsWithPackagesFromUsePackage{
        config = ./emacs.el;
        defaultInitFile = true;
        package = pkgs.emacs-pgtk;
        alwaysEnsure = true;
      });
    };

    programs.git = {
      enable = true;
      userName = "Neil Burningham";
      userEmail = "kneilb@gmail.com";
      extraConfig = {
        credential.helper = "store";
        init.defaultBranch = "main";
        fetch.prune = "true";
        merge.ff = "false";
        pull.ff = "only";
      };
      aliases = {
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        lom = "log --merges --first-parent HEAD --pretty=format:\"%h %<(16,trunc)%an %<(15)%ar %s\"";
        lomm = "log --merges --first-parent origin/master --pretty=format:\"%h %<(16,trunc)%an %<(15)%ar %s\"";
        sti = "ls-files -i --exclude-standard";
      };
      ignores = [
        "*~"
        "cscope.*"
        "GPATH"
        "GRTAGS"
        "GSYMS"
        "GTAGS"
      ];
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = false; # Using fzf-fish instead
    };

    programs.fish = {
      enable = true;

      plugins = [
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
        { name = "tide"; src = pkgs.fishPlugins.tide.src; }
        { name = "z"; src = pkgs.fishPlugins.z.src; }
        {
          name = "fishbang";
          src = pkgs.fetchFromGitHub {
            owner = "BrewingWeasel";
            repo = "fishbang";
            rev = "0b5ef82ead524a7dd0da5760d8f677b02b35f654";
            sha256 = "AbFSUz2C4ru0jclF60JOpzf7xWo0ffahEsM5hkNNtGw=";
          };
        }
        # Trying fishbang instead...! 
        #{
        #  name = "bangbang";
        #  src = pkgs.fetchFromGitHub {
        #    owner = "oh-my-fish";
        #    repo = "plugin-bang-bang";
        #    rev = "ec991b80ba7d4dda7a962167b036efc5c2d79419";
        #    sha256 = "oPPCtFN2DPuM//c48SXb4TrFRjJtccg0YPXcAo0Lxq0=";
        #  };
        #}
        # Not sure we actually need this...
        #{
        #  name = "kubectl-completions";
        #  src = pkgs.fetchFromGitHub {
        #    owner = "evanlucas";
        #    repo = "fish-kubectl-completions";
        #    rev = "ced676392575d618d8b80b3895cdc3159be3f628";
        #    sha256 = "OYiYTW+g71vD9NWOcX1i2/TaQfAg+c2dJZ5ohwWSDCc=";
        #  };
        #}
      ];

      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    # Configure fish's tide prompt - but after the write boundary!
    home.activation.configure-tide = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.fish}/bin/fish -c "tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='One line' --prompt_spacing=Sparse --icons='Few icons' --transient=No"
    '';
  };
}
