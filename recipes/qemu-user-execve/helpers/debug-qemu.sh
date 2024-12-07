#!/bin/bash
set -x

QEMU_BIN="$1"
TEST_BINARY="$2"
ARCH_ARG="$3"

{
    echo "=== Basic Information ==="
    echo "Start time: $(date)"
    echo "Current directory: $(pwd)"
    echo "QEMU binary: $QEMU_BIN"
    echo "Test binary: $TEST_BINARY"
    echo "CPU path: ${QEMU_CPU_PATH:-not set}"
    env | grep -E '^QEMU_|^_QEMU_'
    cat /proc/sys/vm/mmap_min_addr
    ls -la

    echo -e "\n=== Binary Entry Points ==="
    for file in "$QEMU_BIN" "$TEST_BINARY"; do
        echo "=== $file ==="
        readelf -h "$file" | grep 'Entry point'
        readelf -l "$file" | grep 'interpreter'
    done

    echo -e "\n=== Dynamic Dependencies ==="
    for file in "$QEMU_BIN" "$TEST_BINARY"; do
        echo "=== $file ==="
        ldd "$file" 2>&1 || echo "ldd not available or binary not compatible"
    done

    # echo -e "\n=== Detailed QEMU Debug ==="
    # QEMU_DEBUG=1 \
    # QEMU_STRACE=1 \
    # QEMU_EXECVE="$QEMU_BIN" \
    # QEMU_GUEST_BASE=0x400000 \
    # QEMU_STACK_SIZE=8388608 \
    # QEMU_LOG_FILENAME=qemu-debug-%d.log \
    # "$QEMU_BIN" -E QEMU_CPU_PATH="$QEMU_LD_PREFIX" -d exec,guest_errors,strace -L "$QEMU_LD_PREFIX" "$TEST_BINARY" "$ARCH_ARG" 2>&1
    # echo "Exit code: $?"

    # Test with strace from PREFIX
    echo -e "\n=== Strace Output ==="
    QEMU_DEBUG=1 \
    QEMU_STRACE=1 \
    QEMU_EXECVE="$QEMU_BIN" \
    QEMU_GUEST_BASE=0x400000 \
    QEMU_STACK_SIZE=8388608 \
    QEMU_RESERVED_VA=0x8000000 \
    QEMU_CPU=any \
    QEMU_LOG_FILENAME=qemu-debug-%d.log \
    "$PREFIX/usr/bin/strace" -f -v -e trace=execve,open,stat,mmap,munmap "$QEMU_BIN" -d exec,guest_errors,all -L "$QEMU_LD_PREFIX" "$TEST_BINARY" "$ARCH_ARG" 2>&1

    echo -e "\n=== Dynamic Linker Info ==="
    ls -l "${QEMU_LD_PREFIX}"/lib/ld-* 2>&1
    ls -l "${QEMU_LD_PREFIX}"/lib64/ld-* 2>&1 || true

    echo -e "\n=== Environment ==="
    env | grep -E 'QEMU|PREFIX|LD_|PATH'

    echo -e "\n=== End: $(date) ==="
} > debug_output.log 2>&1
