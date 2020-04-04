#!/bin/bash
set -e
lfzip-nlms --help
lfzip-nlms -m c -i data/evaluation_datasets/gas/HT_Sensor_dataset_combined.npy -o tmptmp.bsc -a 1.0 0.01 0.1 1e-4 0.1 0.001 0.1 0.01 --quantization_bytes 1 2 1 1 2 2 2 1 --NLMS_order 64 8 32 1 10 22 2 16 --mu 0.1 0.4 0.5 0.6 0.7 1.0 1.5 0.5
lfzip-nlms -m d -i tmptmp.bsc -o tmptmp.decomp.npy
cmp tmptmp.decomp.npy tmptmp.bsc.recon.npy
rm -r tmptmp*
echo "Tests completed successfully"
