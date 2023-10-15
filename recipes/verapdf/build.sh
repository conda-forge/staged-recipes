#!/usr/bin/env bash
set -eux
export MAVEN_OPTS="-Xmx1G"

mvn --batch-mode versions:set -DnewVersion=${PKG_VERSION}
mvn --batch-mode -DskipTests clean install

mkdir tmp

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=verapdf
# https://git.slub-dresden.de/digital-preservation/verapdf_package_build/-/blob/master/redhat7/verapdf.spec

pushd tmp
  unzip "../installer/target/verapdf-greenfield-${PKG_VERSION}-installer.zip"
  # configure installation path for unattended installation
  pushd "./verapdf-greenfield-${PKG_VERSION}"
    cp "${SRC_DIR}/auto-install-tmp.xml" auto-install.xml
    sed -iE "s;/tmp/verapdf;${PREFIX}/share/verapdf;" auto-install.xml
    ./verapdf-install auto-install.xml
  popd
popd

mkdir -p "${PREFIX}/bin"

for f in verapdf verapdf-gui ; do
  ln -s "${PREFIX}/share/verapdf/${f}" "${PREFIX}/bin/${f}"
done

rm -rf "${PREFIX}/share/verapdf/Uninstaller"
