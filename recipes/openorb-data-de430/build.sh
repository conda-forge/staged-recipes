#!/bin/bash

# Download and build a binary version of JPL ephemeris
EPH_TYPE=430
EPH_ASCII="header.430_229 ascp1550.430 ascp1650.430 ascp1750.430 ascp1850.430 \
                          ascp1950.430 ascp2050.430 ascp2150.430 ascp2250.430 \
                          ascp2350.430 ascp2450.430 ascp2550.430"

# Download and convert
curl -L -f -s -O "ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de$EPH_TYPE/testpo.$EPH_TYPE"
curl -L -f -s "ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de$EPH_TYPE/{$(echo $EPH_ASCII | tr ' ' ,)}" | asc2eph --eph-type=$EPH_TYPE

# Install
mkdir -p "$PREFIX/share/openorb"
cp -a de${EPH_TYPE}.dat testpo.${EPH_TYPE} "$PREFIX/share/openorb"
