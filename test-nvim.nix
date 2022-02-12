{ pkgs }:

let
  myneovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        set rtp-=~/.config/nvim
      '';
      packages.myVimPackages = with pkgs;
        with vimPlugins; {
          start = [
            plenary-nvim
            # # Theme
            # onedark-vim
            # # Programming Language Specific stuff
            # # Sage
            # vim-sage
            # # Nix
            # vim-nix
            # # Clojure
            # vim-dispatch
            # vim-dispatch-neovim
            # vim-jack-in
            # conjure
            # vim-repeat
            # vim-surround
            # vim-sexp
            # vim-sexp-mappings-for-regular-people
            # # General help
            # vim-slime
            # vim-signify
            # vim-css-color
            # tabular
            # vim-matchup
            # delimitMate
            # nvim-ts-rainbow
            # fzf-vim
            # vim-commentary
            # vim-multiple-cursors
            # which-key-nvim
            # vim-skeleton
            # (nvim-treesitter.withPlugins
            # (plugins: pkgs.tree-sitter.allGrammars))
            # nvim-lspconfig
            # # Completion
            # cmp-nvim-lsp
            # nvim-cmp
            # cmp-buffer
            # cmp-vsnip
            # vim-vsnip
            # cmp-path
          ];
          opt = [ ];
        };
    };
  };
in
myneovim
