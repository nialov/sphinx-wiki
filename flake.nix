{
  description = "nix environment for sphinx-wiki";

  inputs = {
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, pre-commit-hooks, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              luacheck = {
                enable = true;
                name = "luacheck";
                entry = "${pkgs.luaPackages.luacheck}/bin/luacheck";
                files = "\\.(lua)$";
                types = [ "lua" ];
              };
              stylua = {
                enable = true;
                name = "stylua";
                entry = "${pkgs.stylua}/bin/stylua";
                files = "\\.(lua)$";
                types = [ "lua" ];
              };
            };
          };
        };
        devShell = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      });
}
