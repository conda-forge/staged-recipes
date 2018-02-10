#!/bin/bash

# image driver
make -C vic/drivers/image
cp vic/drivers/image/vic_image.exe $PREFIX

# classic driver
make -C vic/drivers/classic
cp vic/drivers/classic/vic_classic.exe $PREFIX

# python driver
# TODO: debug later
# python ./vic/drivers/python/setup.py install
