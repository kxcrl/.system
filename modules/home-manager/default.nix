{ pkgs, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
  };

  home = {
    packages = with pkgs; [
      gnupg
      tree
      watch
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    stateVersion = "23.05";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Kai";
    userEmail = "kai.couts@gmail.com";
    lfs.enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.ssh = {
    enable = true;
    controlPath = "none";
  };
  
  programs.waybar = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    localVariables = {
      RPROMPT = null;
    };
    shellAliases =
      let
        update-command =
          if pkgs.stdenv.isLinux
          then "sudo nixos-rebuild"
          else "darwin-rebuild";
      in
      {
        update = ''
          cd ~/.system \
            && ${update-command} switch --flake . \
            && exec $SHELL
        '';
      };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
