#!/bin/bash

package_name="chromIDEAS"

# set -e: exit if run fail
# set -o pipefail: the return value of a pipeline (|) is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline  exit  successfully.
set -e
set -o pipefail

# cp additional scripts file to ${PREFIX}/share
# bin:			${PREFIX}/share/${package_name}/bin
# blacklist:	${PREFIX}/share/${package_name}/blacklist
# genomesize:	${PREFIX}/share/${package_name}/genomesize
# gsl:			${PREFIX}/share/${package_name}/gsl
# manuals:		${PREFIX}/share/${package_name}/manuals
mkdir -p ${PREFIX}/share/${package_name}
if [[ ! -d ${PREFIX}/bin ]]; then
	mkdir -p ${PREFIX}/bin/
fi

cp -rf ${SRC_DIR}/share/bin ${PREFIX}/share/${package_name}
cp -rf ${SRC_DIR}/share/blacklist ${PREFIX}/share/${package_name}
cp -rf ${SRC_DIR}/share/genomesize ${PREFIX}/share/${package_name}
cp -rf ${SRC_DIR}/share/manuals ${PREFIX}/share/${package_name}
cp -rf ${SRC_DIR}/share/gsl ${PREFIX}/share/${package_name}
tar xf ${PREFIX}/share/${package_name}/gsl/gsl_221.tar.gz -C ${PREFIX}/share/${package_name}/gsl/
rm -rf ${PREFIX}/share/${package_name}/gsl/gsl_221.tar.gz

cp -rf ${SRC_DIR}/bins/* ${PREFIX}/bin/

