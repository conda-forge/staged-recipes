#!/bin/bash

find python/tests -name "*.py" | parallel "$PYTHON {}"
