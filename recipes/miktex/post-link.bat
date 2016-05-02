@echo off
rem latex packages which are needed by nbconvert and probably other pdf producers
rem this is just a convenience install: miktex will install any missing package on the fly
rem don't check for errors so that this succeeds even if offline, etc...
%PREFIX%\Library\miktex\miktex\bin\mpm --update-db --quiet
for %%x in (adjustbox booktabs collectbox fancyvrb ifoddpage mptopdf ucs url caption xcolor upquote ulem mathpazo) do (
	%PREFIX%\Library\miktex\miktex\bin\mpm --quiet --install %%x >NUL 2>&1
)
rem No final check as this should succeed even if the conda package is updated and the latex packages are already installed
