#!/bin/bash
set -euxo pipefail

sysroot=$PREFIX/xclang/$XCLANG_TRIPLE
case $XCLANG_TRIPLE in
  x86_64-*)  chkstk=___chkstk_ms ;;
  aarch64-*) chkstk=__chkstk ;;
esac

cat > hello.c <<'SRC'
#include <windows.h>
#include <stdio.h>
int main(void) {
    printf("%lu\n", (unsigned long)GetCurrentProcessId());
    return 0;
}
SRC
# The CRT's pseudo-relocator calls the compiler's stack probe, a compiler-rt
# builtin that ships with the toolchain, not the sysroot. A no-op probe
# stands in for it here so the link exercises every sysroot library.
printf '.globl %s\n%s:\n  ret\n' $chkstk $chkstk > chkstk.S

clang --target=$XCLANG_TRIPLE --sysroot=$sysroot -c hello.c -o hello.o
clang --target=$XCLANG_TRIPLE --sysroot=$sysroot -c chkstk.S -o chkstk.o
clang --target=$XCLANG_TRIPLE --sysroot=$sysroot -fuse-ld=lld -nostdlib \
  $sysroot/lib/crt2.o hello.o chkstk.o -lmingw32 -lmingwex -lucrt -lkernel32 -luser32 -o hello.exe
llvm-readobj --file-headers hello.exe | grep IMAGE_FILE_MACHINE
