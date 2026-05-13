#!/bin/bash
set -ex

meson build
ninja -C build
ninja -C build install
