#!/usr/bin/env bash

set -e

print_double_line() {
	echo ================================================================================
}

print_line() {
	echo --------------------------------------------------------------------------------
}

printerr() {
	printf '%s\n' "$@" >&2
	exit 1
}

install_libmadam() (
	cd "$SRC_DIR" || return

	print_line
	echo 'Running autogen.sh...'
	./autogen.sh

	print_line
	echo 'Running configure...'
	FCFLAGS="-O3 -fPIC -pthread" \
		CFLAGS="-O3 -fPIC -pthread" \
		MPIFC=mpifort \
		./configure --prefix="$PREFIX"

	print_line
	echo 'Running make...'
	make

	print_line
	echo 'Checking...'
	make check

	print_line
	echo 'Running make install...'
	make install

	print_line
	echo 'Installing libmadam Python wrapper...'
	cd "$SRC_DIR/python" || return
	python setup.py install

	print_line
	echo 'Run libmadam test...'
	python setup.py test
)

test_libmadam() (
	print_line
	echo 'Run libmadam test...'
	cd "$SRC_DIR/python" || return
	python setup.py test
)

print_double_line
case "${BASH_SOURCE##*/}" in
build.sh)
	install_libmadam
	;;
run_test.sh)
	test_libmadam
	;;
*)
	echo printerr "unknown BASE_SOURCE $BASH_SOURCE"
	;;
esac
print_double_line
