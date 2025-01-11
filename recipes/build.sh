#!/bin/bash
cmake -B build --preset conda
ninja -C build install
