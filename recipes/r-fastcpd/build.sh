#!/bin/bash

${R} --slave -e "install.packages('fastglm', repos = 'https://cloud.r-project.org')"
${R} CMD INSTALL --build . ${R_ARGS}

