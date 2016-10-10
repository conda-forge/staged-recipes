#!/usr/bin/env bash

gdb -batch -ex "run" -ex "py-bt" --args python "$RECIPE_DIR/testing/process_to_debug.py" | tee gdb_output
grep "line 3" gdb_output
grep "process_to_debug.py" gdb_output
grep 'os.kill(os.getpid(), signal.SIGSEGV)' gdb_output
