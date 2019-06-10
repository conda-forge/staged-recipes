#!/bin/bash
ldd libqxcb.so
echo "coucou"
xvfb-run python -c "import BiorbdViz" 

