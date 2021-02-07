#!/usr/bin/env bash
set -eux
export IPFS_PATH=$(pwd)/.ipfs-repo

echo "does it init"
ipfs --debug init
ls -lathr $IPFS_PATH

echo "does it fetch"
ipfs --debug cat /ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/readme | tee readme
cat readme | grep Hello

echo "does it add"
ipfs --debug add readme | tee added.txt
cat added.txt | grep QmPZ9gcCEpqKTo6aq61g2nXGUhM4iCL3ewB6LDXZCtioEB
