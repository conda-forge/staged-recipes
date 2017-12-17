#!/bin/bash
$R CMD INSTALL --build . --configure-args=" --with-Rmpi-type=MPICH2"
