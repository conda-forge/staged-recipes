#!/bin/bash

# Download and build a binary version of JPL ephemeris
EPH_TYPE=405
EPH_ASCII="header.405 ascp1600.405 ascp1620.405 ascp1640.405 ascp1660.405 ascp1680.405 \
                      ascp1700.405 ascp1720.405 ascp1740.405 ascp1760.405 ascp1780.405 \
                      ascp1800.405 ascp1820.405 ascp1840.405 ascp1860.405 ascp1880.405 \
                      ascp1900.405 ascp1920.405 ascp1940.405 ascp1960.405 ascp1980.405 \
                      ascp2000.405 ascp2020.405 ascp2040.405 ascp2060.405 ascp2080.405 \
                      ascp2100.405 ascp2120.405 ascp2140.405 ascp2160.405 ascp2180.405 \
                      ascp2200.405"

# Download and convert
curl -L -f -s -O "ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de$EPH_TYPE/testpo.$EPH_TYPE"
curl -L -f -s "ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de$EPH_TYPE/{$(echo $EPH_ASCII | tr ' ' ,)}" | asc2eph --eph-type=$EPH_TYPE

# Install
mkdir -p "$PREFIX/share/openorb"
cp -a de${EPH_TYPE}.dat testpo.${EPH_TYPE} "$PREFIX/share/openorb"
