#!/usr/bin/env bash

set -euxo pipefail

export XDG_CONFIG_DIRS=""
nix develop --unset PATH -c pre-commit run --all-files
nix develop --unset PATH -c nvim --noplugin --headless -c 'PlenaryBustedDirectory tests' -c 'cq'

