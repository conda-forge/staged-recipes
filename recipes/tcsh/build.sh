#!/bin/bash

#set -eu -o pipefail

ls -l /lib64
eval ./configure
cat config.log 

