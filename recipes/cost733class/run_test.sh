#! /usr/bin/env bash
test -f $PREFIX/bin/cost733class

$PREFIX/bin/cost733class -v 3 -dat  pth:slp.dat  lon:-10:30:2.5  lat:35:60:2.5 fdt:2000:1:1:12 ldt:2008:12:31:12 ddt:1d
