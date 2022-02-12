{ pkgs }:

let
  myneovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        set runtimepath+=${pkgs.vimPlugins.plenary-nvim}

        runtime! plugin/plenary.vim
      '';
      packages.myVimPackages = with pkgs;
        with vimPlugins; {
          start = [ plenary-nvim ];
          opt = [ ];
        };
    };
  };
in
myneovim
