echo $CMDSTAN

cd $PREFIX/bin/cmdstan
# bernoulli example
make examples/bernoulli/bernoulli
./examples/bernoulli/bernoulli sample data file=examples/bernoulli/bernoulli.data.json
bin/stansummary output.csv

# check binaries 
bin/stanc --help
bin/stansummary --help

# python3 runCmdStanTests.py src/test/interface/
