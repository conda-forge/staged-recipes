@echo off
setlocal disableDelayedExpansion
REM Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%

setlocal enableDelayedExpansion

%${%PYTHON% setup.py install

endlocal
endlocal