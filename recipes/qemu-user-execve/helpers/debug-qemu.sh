#!/bin/bash
set -x
QEMU_BIN="$1"
TEST_BINARY="$2"
ARCH_ARG="$3"

# [Previous functions remain the same]

{
    # [Previous sections remain the same]

    echo -e "\n=== Pre-execution Memory Info ==="
    free -m
    ulimit -a
    grep -i memtotal /proc/meminfo
    grep -i commit /proc/meminfo

    echo -e "\n=== Test cgroup ==="
    mount | grep cgroup
    stat -f -c %T /sys/fs/cgroup

    echo -e "\n=== Mem limit ==="
    cat /sys/fs/cgroup/memory/memory.limit_in_bytes
    cat /proc/sys/vm/overcommit_memory
    cat /proc/sys/vm/overcommit_ratio

    echo -e "\n=== Strace Output ==="
    # Set larger stack size and disable address randomization
    ulimit -s unlimited
    echo 0 > /proc/sys/kernel/randomize_va_space 2>/dev/null || true

    QEMU_DEBUG=2 \
    QEMU_STRACE=1 \
    QEMU_MEMTX_PERM=0 \
    QEMU_STACK_SIZE=8192 \
    QEMU_GUEST_BASE=0x40000000 \
    QEMU_LOG=guest_errors,page,exec,unimp \
    QEMU_LOG_FILENAME=qemu-debug-%d.log \
    LD_DEBUG=all \
    LD_DEBUG_OUTPUT=ld.log \
    "$PREFIX/usr/bin/strace" -f -v -s 2048 -x \
    -e trace=prctl,seccomp,mmap,mprotect,personality,security,exit_group,exit,signal,write,open,close,execve \
    -e fault=none \
    "$QEMU_BIN" $QEMU_CPU_ARG \
    -L "$QEMU_LD_PREFIX" \
    "$TEST_BINARY" "$ARCH_ARG" 2>&1

    EXIT_CODE=$?
    echo "Exit code: $EXIT_CODE"

    echo -e "\n=== Post-execution Memory Info ==="
    free -m

    echo -e "\n=== Memory Map ==="
    cat /proc/self/maps || true

    # [Rest of the script remains the same]
} | tee -a debug_output.log