curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

rustup install nightly
rustup override set nightly

cd y-py; $PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
