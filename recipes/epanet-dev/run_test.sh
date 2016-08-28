git clone https://github.com/OpenWaterAnalytics/epanet-example-networks.git
mkdir rpt
for f in ./epanet-example-networks/*/*.inp; do
    fout=$(basename $f);
    run-epanet3 ${f} "rpt/${fout%.inp}-rpt.txt";
done
