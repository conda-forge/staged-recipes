#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cat > test.c << EOF
#include <unibilium.h>
#include <stdio.h>
int main()
{
	setvbuf(stdout, NULL, _IOLBF, 0);
	unibi_term *ut = unibi_dummy();
	unibi_destroy(ut);
	return 0;
}
EOF

"${CC}" $CPPFLAGS $CFLAGS $LDFLAGS test.c -lunibilium -o test
./test
