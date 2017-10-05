# First, build go1.4 using gcc, then use that go to build go>1.4
mkdir go-bootstrap && pushd $_

BOOTSTRAP_TARBALL=go1.4-bootstrap-20170531.tar.gz
# https://storage.googleapis.com/golang/go1.4-bootstrap-20170531.tar.gz.sha256
BOOTSTRAP_TARBALL_CHECKSUM=49f806f66762077861b7de7081f586995940772d29d4c45068c134441a743fa2

curl -LO https://storage.googleapis.com/golang/${BOOTSTRAP_TARBALL}
tar -xzf ${BOOTSTRAP_TARBALL}
[ $(openssl sha -sha256 "${BOOTSTRAP_TARBALL}" | awk '{print $2}') == "${BOOTSTRAP_TARBALL_CHECKSUM}" ] || exit 1
rm -f ${BOOTSTRAP_TARBALL}
export GOROOT_BOOTSTRAP=$PWD/go
cd $GOROOT_BOOTSTRAP/src
./make.bash

pushd $SRC_DIR/src
if [[ $(uname) == 'Darwin' ]]; then
  # Tests on macOS receive SIGABRT on Travis :-/
  # All tests run fine on Mac OS X:10.9.5:13F1911 locally
  ./make.bash
elif [[ $(uname) == 'Linux' ]]; then
  ./all.bash
fi

rm -fr ${GOROOT_BOOTSTRAP}
mkdir -p ${PREFIX}/go
# Dropping the verbose option here, because Travis chokes on output >4MB
cp -r $SRC_DIR/* ${PREFIX}/go/
rm -f ${PREFIX}/go/conda_build.sh

# Right now, it's just go and gofmt, but might be more in the future!
mkdir -p ${PREFIX}/bin && pushd $_
for binary in ../go/bin/* ; do ln -s $binary ; done

# Install [de]activate scripts.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
