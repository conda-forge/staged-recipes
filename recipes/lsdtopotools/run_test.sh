#! bash

curl -L https://github.com/LSDtopotools/ExampleTopoDatasets/tarball/master | tar xz
cd LSDtopotools-ExampleTopoDatasets-*/BasicMetricsData

for driver in *driver; do
  lsdtt-basic-metrics $driver;
done
