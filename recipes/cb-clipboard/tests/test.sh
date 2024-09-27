#!/bin/bash

export CLIPBOARD_FORCETTY=1
export CLIPBOARD_NOGUI=1

cb copy ${RECIPE_DIR}/CB.png
cb paste
if [[ ! -f CB.png ]]; then
  echo "Test failed: CB.png was not found"
  exit 1
fi
