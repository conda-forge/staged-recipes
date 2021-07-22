:: run bernoulli example
cd %PREFIX%\Library\bin\cmdstan
mingw32-make examples/bernoulli/bernoulli.exe
if errorlevel 1 exit 1
examples\bernoulli\bernoulli.exe 
examples\bernoulli\bernoulli.exe sample data file=examples/bernoulli/bernoulli.data.json
if errorlevel 1 exit 1
bin\stansummary.exe output.csv
if errorlevel 1 exit 1

:: test binaries
bin\stanc.exe --help
if errorlevel 1 exit 1
bin\stansummary.exe --help
if errorlevel 1 exit 1
