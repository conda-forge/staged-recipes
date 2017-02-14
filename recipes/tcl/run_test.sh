#!/usr/bin/env bash


echo "puts \"hello\"" >> t.tcl
tclsh8.5 t.tcl | grep hello 
