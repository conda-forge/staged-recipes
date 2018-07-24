
# Force the setup.cfg
cat > setup.cfg << EOF
[config_fc]
opt=-fopenmp -O3 -funroll-loops
[build_ext]
libraries=gomp
EOF

# Prevent CDAT asking for usage logging
export UVCDAT_ANONYMOUS_LOG=no

# Standard installation
python -m pip install --no-deps --ignore-installed .
