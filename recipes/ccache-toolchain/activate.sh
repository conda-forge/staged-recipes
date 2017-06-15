#!/bin/bash

export _OLD_PATH=${PATH}
export PATH="${PREFIX}/bin/conda_forge_ccache:${PATH}"
