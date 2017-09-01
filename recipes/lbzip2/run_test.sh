#!/usr/bin/env bash

# compare lbzip2's output against output from bzip2 1.0.6
echo "uncompressed" | lbzip2 -c > lbzip2.out
dd if=lbzip2.out ibs=1 skip=10 count=4 2>/dev/null > lbzip2.crc
[[ $(hexdump -e '1/1 "%02x"' lbzip2.crc) == "6a8eb39c" ]] || exit 1
