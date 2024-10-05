#!/bin/bash
sudo apt-get update
sudo apt-get install -y xvfb
python -m pip install --no-deps --ignore-installed .
