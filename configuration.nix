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
  networking.hostName = "beastie";
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
    pkgs.grc
    pkgs.wget
    pkgs.unzip
    pkgs.yq

    pkgs.dust # Disk usage analyser
    pkgs.ncdu # Disk usage analyser

    pkgs.devenv

    # Do these via devenvs instead
    # pkgs.cmake
    # pkgs.gcc
    # pkgs.gnumake
    # pkgs.gdb

    # pkgs.python3

    # Needed for tide prompt
    pkgs.kubectl
  ];

  programs = {
    fish.enable = true;
    mtr.enable = true; # Network cross between ping & traceroute
  };

  home-manager.users.kneilb = {
    home.stateVersion = "${stateVersion}"; # Did you read the comment?

    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override { fonts = ["FiraCode" "FiraMono" "Hack" "Meslo"]; })
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
        package = pkgs.emacs;
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

        # tide prompt
        set --global tide_character_color 5FD700
        set --global tide_character_color_failure FF0000
        set --global tide_character_icon \u276f
        set --global tide_character_vi_icon_default \u276e
        set --global tide_character_vi_icon_replace \u25b6
        set --global tide_character_vi_icon_visual V
        set --global tide_chruby_bg_color B31209
        set --global tide_chruby_color 000000
        set --global tide_chruby_icon \ue23e
        set --global tide_cmd_duration_bg_color C4A000
        set --global tide_cmd_duration_color 000000
        set --global tide_cmd_duration_decimals 0
        set --global tide_cmd_duration_icon \x1d
        set --global tide_cmd_duration_threshold 3000
        set --global tide_context_always_display false
        set --global tide_context_bg_color 444444
        set --global tide_context_color_default D7AF87
        set --global tide_context_color_root D7AF00
        set --global tide_context_color_ssh D7AF87
        set --global tide_git_bg_color 4E9A06
        set --global tide_git_bg_color_unstable C4A000
        set --global tide_git_bg_color_urgent CC0000
        set --global tide_git_color_branch 000000
        set --global tide_git_color_conflicted 000000
        set --global tide_git_color_dirty 000000
        set --global tide_git_color_operation 000000
        set --global tide_git_color_staged 000000
        set --global tide_git_color_stash 000000
        set --global tide_git_color_untracked 000000
        set --global tide_git_color_upstream 000000
        set --global tide_git_icon \x1d
        set --global tide_go_bg_color 00ACD7
        set --global tide_go_color 000000
        set --global tide_go_icon \ue627
        set --global tide_jobs_bg_color 444444
        set --global tide_jobs_color 4E9A06
        set --global tide_jobs_icon \uf013
        set --global tide_kubectl_bg_color 326CE5
        set --global tide_kubectl_color 000000
        set --global tide_kubectl_icon \u2388
        set --global tide_left_prompt_frame_enabled false
        set --global tide_left_prompt_items pwd git
        set --global tide_left_prompt_prefix
        set --global tide_left_prompt_separator_diff_color \ue0b0
        set --global tide_left_prompt_separator_same_color \ue0b1
        set --global tide_left_prompt_suffix \ue0b0
        set --global tide_node_bg_color 44883E
        set --global tide_node_color 000000
        set --global tide_node_icon \u2b22
        set --global tide_os_bg_color CED7CF
        set --global tide_os_color 080808
        set --global tide_os_icon \uf31b
        set --global tide_php_bg_color 617CBE
        set --global tide_php_color 000000
        set --global tide_php_icon \ue608
        set --global tide_prompt_add_newline_before true
        set --global tide_prompt_color_frame_and_connection 6C6C6C
        set --global tide_prompt_color_separator_same_color 949494
        set --global tide_prompt_icon_connection \x20
        set --global tide_prompt_min_cols 26
        set --global tide_prompt_pad_items true
        set --global tide_pwd_bg_color 3465A4
        set --global tide_pwd_color_anchors E4E4E4
        set --global tide_pwd_color_dirs E4E4E4
        set --global tide_pwd_color_truncated_dirs BCBCBC
        set --global tide_pwd_icon \x1d
        set --global tide_pwd_icon_home \x1d
        set --global tide_pwd_icon_unwritable \uf023
        set --global tide_pwd_markers .bzr .citc .git .hg .node_version .python_version .ruby_version .shorten_folder_marker .svn .terraform Cargo.toml composer.json CVS go.mod package.json
        set --global tide_right_prompt_frame_enabled false
        set --global tide_right_prompt_items status cmd_duration context jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
        set --global tide_right_prompt_prefix \ue0b2
        set --global tide_right_prompt_separator_diff_color \ue0b2
        set --global tide_right_prompt_separator_same_color \ue0b3
        set --global tide_right_prompt_suffix
        set --global tide_rustc_bg_color F74C00
        set --global tide_rustc_color 000000
        set --global tide_rustc_icon \ue7a8
        set --global tide_shlvl_bg_color 808000
        set --global tide_shlvl_color 000000
        set --global tide_shlvl_icon \uf120
        set --global tide_shlvl_threshold 1
        set --global tide_status_bg_color 2E3436
        set --global tide_status_bg_color_failure CC0000
        set --global tide_status_color 4E9A06
        set --global tide_status_color_failure FFFF00
        set --global tide_status_icon \u2714
        set --global tide_status_icon_failure \u2718
        set --global tide_terraform_bg_color 800080
        set --global tide_terraform_color 000000
        set --global tide_terraform_icon \x1d
        set --global tide_time_bg_color D3D7CF
        set --global tide_time_color 000000
        set --global tide_time_format
        set --global tide_vi_mode_bg_color_default 008000
        set --global tide_vi_mode_bg_color_replace 808000
        set --global tide_vi_mode_bg_color_visual 000080
        set --global tide_vi_mode_color_default 000000
        set --global tide_vi_mode_color_replace 000000
        set --global tide_vi_mode_color_visual 000000
        set --global tide_vi_mode_icon_default DEFAULT
        set --global tide_vi_mode_icon_replace REPLACE
        set --global tide_vi_mode_icon_visual VISUAL
        set --global tide_virtual_env_bg_color 444444
        set --global tide_virtual_env_color 00AFAF
        set --global tide_virtual_env_icon \ue73c
      '';
    };
  };
}
