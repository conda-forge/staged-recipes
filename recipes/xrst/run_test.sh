#! /usr/bin/env bash
set -e -u
#
# prefix, name, version
prefix=$PREFIX
name=$PKG_NAME
version=$PKG_VERSION
#
# url
home="https://github.com/bradbell/$name"
url="$home/archive/$version.tar.gz"
#
# xrst-$version.tar.gz
curl -LJO $url
#
# xrst-$version
tar -xzf xrst-$version.tar.gz
cd xrst-$version
#
# xrst-$version/pytest/test_rst.py
sed -i pytest/test_rst.py \
   -e  "s|'python3' *,.*|'$prefix/bin/xrst', '--suppress_spell_warnings', |"
#
# xrst-$version/xrst.toml
sed -i xrst.toml \
   -e 's|pyenchant|pyspellchecker|'
#
# pytest
pytest -s pytest
#
echo 'run_test.sh: OK'
exit 0

