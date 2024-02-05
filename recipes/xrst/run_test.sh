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
sed -i \
   -e  "s|'python3' *,.*|'$prefix/bin/xrst', '--suppress_spell_warnings', |" \
   pytest/test_rst.py
#
# xrst-$version/xrst.toml
sed -i -e 's|pyenchant|pyspellchecker|' xrst.toml
#
# pytest
pytest -s pytest
#
echo 'run_test.sh: OK'
exit 0

