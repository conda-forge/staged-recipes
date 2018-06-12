#!/bin/bash

find python/tests -name "*.py" | sed /mpb/d | parallel "$PYTHON {}"
