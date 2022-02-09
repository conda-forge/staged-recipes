#!/bin/bash

# just 'install' stuff
install -d -m 0755 "${EPICS_BASE}/extensions"
cp -rv "${SRC_DIR}/configure" "${EPICS_BASE}/extensions/"
