#!/usr/bin/env bash

pushd src
  mkdir ${PREFIX}/bin || true
  cp CovidSim ${PREFIX}/bin
popd
