#!/bin/bash

mkdir -vp ${PREFIX}/bin;

cp -v argo ${PREFIX}/bin/argo || exit 1;
chmod -v 755 ${PREFIX}/bin/argo || exit 1;
