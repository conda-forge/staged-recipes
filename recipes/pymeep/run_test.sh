#!/bin/bash

OPENBLAS_NUM_THREADS=1 find python/tests -name "*.py" | sed /mpb/d | parallel "$PYTHON {}"
