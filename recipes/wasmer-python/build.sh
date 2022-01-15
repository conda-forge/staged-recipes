cargo install just
just prelude
source .env/bin/activate
just build api
just build compiler-cranelift
# python examples/appendices/simple.py