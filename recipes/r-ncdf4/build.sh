#!/bin/bash

$R CMD INSTALL --configure-args="--with-nc-config=$PREFIX/bin/nc-config" --build .
