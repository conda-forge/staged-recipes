# from https://github.com/Homebrew/homebrew-core/blob/master/Formula/semgrep.rb
opam init --disable-sandboxing --no-setup # disable-sandboxing needed because I'm not sure we have bwrap
opam switch create ocaml-base-compiler.4.10.2

# Patch Semgrep's Makefile so it will patch ocaml-tree-sitter BUT ONLY AFTER git submodule is initialized.
# This patch will in turn make Semgrep Makefile patch the script in ocaml-tree-sitter
git apply 0001-patch-ocaml-tree-sitter-submodule-to-remove-sudo.patch

opam exec -- make setup

cd spacegrep
  opam install --deps-only -y .
  opam exec -- make
  opam exec -- make install
  cp _build/default/src/bin/Space_main.exe $PREFIX/spacegrep # copy to top-level of Python source?
  cp _build/default/src/bin/Space_main.exe $PREFIX/bin/spacegrep
  cd ..

cd ocaml-tree-sitter
  cd tree-sitter
    opam exec -- make
    opam exec -- make install
    cd ..
  opam install -y .
  cd ..

cd semgrep-core
  opam install --deps-only -y .
  opam exec -- make all
  opam exec -- make install
  cp _build/install/default/bin/semgrep-core $PREFIX/semgrep-core # copy to top-level of Python source?
  cp _build/install/default/bin/semgrep-core $PREFIX/bin/semgrep-core
  cd ..

# Hopefully Python semgrep setup can find the binaries in either of these two places

# From Grayskull's output:
$PYTHON -m pip install . -vv