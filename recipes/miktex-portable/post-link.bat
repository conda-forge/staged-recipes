rem latex packages which are needed by nbconvert and other pdf producers
rem don't check for errors so that this succeeds even if offline, etc...
%PREFIX%\Library\miktex-portable\miktex\bin\mpm --update-db --quiet
for %%x in (adjustbox booktabs collectbox fancyvrb ifoddpage mptopdf ucs url) do (
	%PREFIX%\Library\miktex-portable\miktex\bin\mpm --quiet --install %%x
)
rem No final check as this should succeed even if the conda package is updated and the latex packages already installed
