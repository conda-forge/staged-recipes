#!/bin/bash

set -e -o pipefail

PKG_HOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mv Natural_Docs_*.hide Natural_Docs_2.0.1.zip
unzip Natural_Docs_2.0.1.zip 2> unzip_err.txt || true
echo 'warning:  Natural_Docs_2.0.1.zip appears to use backslashes as path separators' > unzip_err_expected.txt
diff -q unzip_err.txt unzip_err_expected.txt

mkdir -p ${PKG_HOME}
cp -R ${SRC_DIR}/'Natural Docs'/* ${PKG_HOME}/

EXE=${PKG_HOME}/NaturalDocs.exe
ND=${PREFIX}/bin/NaturalDocs
echo "#!/bin/bash" > $ND
echo "set -e -o pipefail" >> $ND
echo "mono $EXE" >> $ND
chmod u+x $ND

cp ${SRC_DIR}/'Natural Docs'/License.txt .

