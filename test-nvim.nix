{ pkgs }:

let
  myneovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        set runtimepath+=${pkgs.vimPlugins.plenary-nvim}

        runtime! plugin/plenary.vim
      '';
      packages.main = with pkgs.vimPlugins; {
        start = [ plenary-nvim ];
        opt = [ ];
      };
    };
  };
in
myneovim
