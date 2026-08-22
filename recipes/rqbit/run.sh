#!/usr/bin/env bash

# example use:
# ./recipes/rqbit/run.sh --http-api-listen-addr 127.0.0.1:3032 server start ~/Downloads/rqbit/

# upload local build to remote machine:
# rsync -rap ~/src/milahu/conda-recipes-rqbit/output/ example.com:src/milahu/conda-recipes-rqbit/output/

# TODO set target glibc version
# get target glibc version:
#   ldd --version | head -n1 | sed 's/^.* //'
# override glibc version:
#   CONDA_OVERRIDE_GLIBC=2.17 rattler-build build --variant-config variant_config.yaml --recipe recipes/rqbit/recipe.yaml
# -> no. "mamba install" still fails with
#   Resolving Environment
#   error    libmamba Could not solve for environment specs
#       The following package could not be installed
#       └─ rqbit =* * is not installable because it requires
#          └─ __glibc >=2.39,<3.0.a0 *, which is missing on the system.
#   critical libmamba Could not solve for environment specs
#
# https://github.com/conda/conda-libmamba-solver/issues/483
# https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-virtual.html#overriding-detected-packages
# no?
# https://stackoverflow.com/questions/70019660/including-glibc-in-a-conda-package
# https://conda-forge.org/docs/maintainer/infrastructure/#centos-sysroot-for-linux--platforms
# https://anaconda.org/channels/conda-forge/packages/sysroot_linux-64/overview
#
# https://github.com/prefix-dev/rattler-build/issues/2585
# virtual packages: cross-compiling packages for glibc 2.17

set -e
set -x # xtrace

# program name
pname=rqbit

env_name=$pname

recipes_dir=$HOME/src/milahu/conda-recipes-$pname
recipes_remote=https://github.com/milahu/staged-recipes
recipes_branch=$pname-init

# isolated mamba root -> higher disk usage
# export MAMBA_ROOT_PREFIX="$recipes_dir/.mamba"

# shared mamba root
export MAMBA_ROOT_PREFIX="$HOME/.mamba"

if ! [ -e $recipes_dir ]; then
  echo fetching $recipes_remote
  git clone --depth=1 $recipes_remote $recipes_dir --branch $recipes_branch
fi

cd $recipes_dir

function exec_pname() {

  # to run this function via nix-shell:
  # export pname env_name

  eval "$(micromamba shell hook --shell bash)"

  echo "MAMBA_ROOT_PREFIX: ${MAMBA_ROOT_PREFIX@Q}"

  # deactivate any previous conda env
  # TODO? make this depend on $CONDA_SHLVL
  micromamba deactivate

  if ! [ -e "$MAMBA_ROOT_PREFIX/envs/$env_name" ]; then
    echo creating env $env_name
    micromamba create --name $env_name
  fi

  echo activating env $env_name
  micromamba activate $env_name

  # print versions of "virtual packages" like glibc
  micromamba info

  if ! ls output/linux-64/$pname-*.conda; then
    echo building $pname
    micromamba install --yes rattler-build conda
    if ! [ -e variant_config.yaml ]; then
      # https://rattler-build.prefix.dev/dev/variants/
      # https://rattler-build.prefix.dev/latest/variants/
      # https://github.com/prefix-dev/pixi/issues/5272
      # https://rattler-build.prefix.dev/dev/reference/jinja/#the-stdlib-function
      {
        echo "c_stdlib:"
        echo "  - sysroot"
        echo "c_compiler:"
        echo "  - gcc"
      } >variant_config.yaml
    fi
    rattler-build build --variant-config variant_config.yaml --recipe recipes/$pname/recipe.yaml
    conda index output
  fi

  if ! command -v $pname; then
    echo installing $pname
    micromamba install -c file://$PWD/output -c conda-forge --yes $pname
  fi

  printf "arg: %q\n" "$@" # debug

  exec $pname "$@"
}

if command -v micromamba; then
  echo using micromamba $(command -v micromamba)
else
  echo installing micromamba
  if command -v nix-shell && [ -e /nix/store ]; then
    # NixOS Linux
    # we need an FHS env because conda executables are linked against /lib64/ld-linux-x86-64.so.2
    # install micromamba to /usr/bin/micromamba and call exec_pname
    expr=""
    expr+='{ runScript }:'$'\n'
    expr+='with import <nixpkgs> {};'$'\n'
    expr+='(buildFHSEnv {'$'\n'
    expr+='  name = "fhs-micromamba-'$pname'";'$'\n'
    expr+='  targetPkgs = _: [ micromamba ];'$'\n'
    expr+='  runScript = runScript;'$'\n'
    expr+='}).env'
    echo "expr for nix-shell:"; echo "$expr" # debug
    bash_cmd=""
    bash_cmd+="exec_pname $(printf "%q " "$@")"$'\n'
    runScript="bash -c ${bash_cmd@Q}"
    export -f exec_pname
    export pname env_name
    exec nix-shell --expr "$expr" --argstr runScript "$runScript"
  else
    # this should work on most other Linux distributions
    # https://github.com/mamba-org/micromamba-releases
    bash <(curl -L https://micro.mamba.pm/install.sh)
  fi
fi

exec_pname "$@"
