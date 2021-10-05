#!/bin/bash

./configure --prefix=$PREFIX BACKENDS="bh canon canon630u canon_dr canon_lide70 cardscan coolscan coolscan2 coolscan3 dc25 dc210 dc240 dell1600n_net dmc epjitsu epson epson2 epsonds fujitsu genesys gt68xx hp hp3500 hp3900 hp4200 hp5400 hp5590 hpljm1005 hs2p ibm kvs1025 kvs20xx kvs40xx leo lexmark ma1509 magicolor matsushita microtek microtek2 mustek mustek_usb mustek_usb2 nec net niash pie pieusb plustek plustek_pp qcam ricoh ricoh2 rts8891 s9036 sceptre sharp snapscan sp15c st400 stv680 tamarack teco1 teco2 teco3 test u12 umax umax_pp umax1220u xerox_mfp p5"

make -j$CPU_COUNT
make install
