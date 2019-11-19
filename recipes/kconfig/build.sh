#!/usr/bin/env bash
set -ex

mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
# CI doesn't allow all tests without 'Child aborted'
bad_tests="kconfigcore-kconfigtest"
bad_tests="${bad_tests}|kconfiggui-kconfigguitest"
bad_tests="${bad_tests}|kconfiggui-kconfigloadertest"
bad_tests="${bad_tests}|kconfiggui-kconfigskeletontest"
bad_tests="${bad_tests}|kconfiggui-kstandardshortcuttest"
bad_tests="${bad_tests}|test\d"
bad_tests="${bad_tests}|test3a"
bad_tests="${bad_tests}|test10"
bad_tests="${bad_tests}|test11"
bad_tests="${bad_tests}|test_dpointer"
bad_tests="${bad_tests}|test_signal"
bad_tests="${bad_tests}|test_notifiers"
bad_tests="${bad_tests}|kconfigcompiler-signals-test"
bad_tests="${bad_tests}|kconfigcompiler-basic-test"
bad_tests="${bad_tests}|test_qdebugcategory"
bad_tests="${bad_tests}|test_translation_qt"
bad_tests="${bad_tests}|test_translation_kde"
bad_tests="${bad_tests}|test_translation_kde_domain"
bad_tests="${bad_tests}|test_fileextensions"
ctest -E "${bad_tests}"
make install
popd
