/*
 * Test that qemu-zig allows writing to executable memory (PROT_WRITE on .text).
 * This is required for Zig's incremental compiler which patches code in-place.
 *
 * Cross-compile with: $CC -static -o test_prot_write test_prot_write.c
 * Run under qemu-zig: qemu-zig-aarch64 ./test_prot_write
 */
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

void target_func(void) { }

int main() {
    long page_size = sysconf(_SC_PAGESIZE);
    void *page = (void *)((long)target_func & ~(page_size - 1));

    /* Try to make .text writable - simulates what zig incremental does */
    if (mprotect(page, page_size, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
        perror("mprotect PROT_WRITE on .text failed");
        return 1;
    }

    printf("PROT_WRITE on .text: OK\n");
    return 0;
}
