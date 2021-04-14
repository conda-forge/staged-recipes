### UNTESTED, from https://github.com/returntocorp/semgrep/tree/develop/doc#installing-from-source
opam init --disable-sandboxing # disable-sandboxing needed because I'm not sure we have bwrap
opam switch create 4.10.0
opam switch 4.10.0
eval $(opam env)
make dev-setup

# From Grayskull's output:
$PYTHON -m pip install . -vv