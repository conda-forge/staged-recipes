#!/usr/bin/env bash
export IPFS_PATH=$(pwd)/.ipfs-repo
ipfs init
ls -lathr $IPFS_PATH
ipfs cat /ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/readme \
  | grep Hello
