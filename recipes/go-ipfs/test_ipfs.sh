#!/usr/bin/env bash
set -eux
export IPFS_PATH=$(pwd)/.ipfs-repo

echo "does it init"
ipfs init
ls -lathr $IPFS_PATH

echo "does it fetch"
ipfs cat /ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/readme | tee readme
cat readme | grep Hello

echo "does it add"
ipfs add readme
