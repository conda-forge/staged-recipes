#!/usr/bin/env bash


echo "puts \"hello\"" >> t.tcl
tclsh t.tcl | grep hello  
