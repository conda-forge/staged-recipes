:: run bernoulli example
cd %PREFIX%\bin\cmdstan
mingw32-make examples/bernoulli/bernoulli.exe
./examples/bernoulli/bernoulli.exe sample data file=examples/bernoulli/bernoulli.data.json
bin/stansummary.exe output.csv

:: test binaries
./bin/stanc.exe
./bin/stansummary.exe
