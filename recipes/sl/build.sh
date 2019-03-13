#! /bin/bash
${CC} ${CFLAGS} ${LDFLAGS} -o sl sl.c -lncurses -ltinfo
mkdir -p ${PREFIX}/bin
cp sl ${PREFIX}/bin/

