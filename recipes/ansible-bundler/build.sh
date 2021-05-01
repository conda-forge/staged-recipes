# Install script adapted from ansible-bundler makefile:
# https://github.com/kriansa/ansible-bundler/blob/v1.10.2/Makefile

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc
mkdir -p ${PREFIX}/lib

LIB_PATH=${PREFIX}/lib/ansible-bundler
ETC_PATH=${PREFIX}/etc/ansible-bundler
VERSION=$(cat VERSION)

cp app/bin/bundle-playbook ${PREFIX}/bin
cp -r app/etc ${PREFIX}/etc/ansible-bundler
cp -r app/lib ${PREFIX}/lib/ansible-bundler

sed -i'' \
  -e "s#LIB_PATH=.*#LIB_PATH=${LIB_PATH}#" \
  -e "s#ETC_PATH=.*#ETC_PATH=${ETC_PATH}#" \
  -e "s#VERSION=.*#VERSION=${VERSION}#" \
  -e "s/%VERSION%/${VERSION}/" \
  ${PREFIX}/bin/bundle-playbook

echo "Built package v${VERSION} in directory '${PREFIX}'"
