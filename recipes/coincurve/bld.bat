@echo off
setlocal disableDelayedExpansion
REM Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%

setlocal enableDelayedExpansion

# Clean-up SOURCES.txt
patch -u setup.py resolve_abs_path_SOURCES.txt.patch

%PYTHON% setup.py install

endlocal
endlocal