#!/bin/bash

set -eu -o pipefail

ls -l /usr/lib64
eval ./configure
cat config.log 
exit
