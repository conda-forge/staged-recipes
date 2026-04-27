#!/bin/bash

export DISABLE_AUTOBUILD=1

$R CMD INSTALL --build . ${R_ARGS}
