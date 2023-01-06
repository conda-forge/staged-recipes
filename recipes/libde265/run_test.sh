git clone https://github.com/strukturag/libde265-data.git
dec265 -q -c -f 100 ./libde265-data/IDR-only/paris-352x288-intra.bin
dec265 -t 4 -q -c -f 100 ./libde265-data/IDR-only/paris-352x288-intra.bin
dec265 -0 -q -c -f 100 ./libde265-data/RandomAccess/paris-ra-wpp.bin
dec265 -0 -t 4 -q -c -f 100 ./libde265-data/RandomAccess/paris-ra-wpp.bin
