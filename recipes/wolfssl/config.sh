
set -ex

# this is separate to easily keep
# run_test.sh and build.sh using the
# same configure args except run_test.sh
# also passes --enable-nolibrary
# so that it will build and run tests using 
# the installed library from the package
#
# --enable-jobserver=no is an attempt to serialize
# the tests.  something in their automake hardcodes
# make to -j2 and they have warnings all over about
# port conflicts between their tests.

./configure --prefix="$PREFIX" \
	    --with-libz="$PREFIX" \
	    --enable-jobserver=no \
	    --enable-distro \
	    "$@"

# hack the Automake build-aux/test-driver
# to put a 5m timeout on tests.  Doing it here
# because it will properly record individual test
# failure and give me a log to look at
perl -i.bk -pe 's/^(?=\"\$@\")/timeout -k5 5m /' build-aux/test-driver
diff -U3 build-aux/test-driver{.bk,}
