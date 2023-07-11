#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
apt-get install -y libxslt1-dev
