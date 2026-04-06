# QEMU Patch Layers

This directory contains patches organized by layer for the qemu-user-patched feedstock.

## Patch Layers

### Layer 0: Base (`base/`)
Stability patches applied to ALL package variants. These come primarily from Zig's QEMU fork.

| Patch | Source | Status | Description |
|-------|--------|--------|-------------|
| `missing-RESOLVE_CACHED.patch` | qemu-execve | ✅ Present | Adds missing `RESOLVE_CACHED` define for `openat2` |
| `0001-linux-user-signal-fixes.patch` | Zig fork | ❌ TODO | Signal handling improvements |
| `0002-linux-user-syscall-fixes.patch` | Zig fork | ❌ TODO | System call handling improvements |
| `0003-fix-mremap-unmapping.patch` | Zig fork | ❌ TODO | Fixes mremap memory unmapping |
| `0004-fix-mremap-errors.patch` | Zig fork | ❌ TODO | Memory error handling in mremap |
| `0005-fix-reserved_va-page-leak.patch` | Zig fork | ❌ TODO | Memory leak fix in reserved VA |

### Layer 1: execve (`execve/`)
Patches for execve interception (qemu-execve packages).

| Patch | Source | Status | Description |
|-------|--------|--------|-------------|
| `apply-execve-JH.patch` | Joel Holdsworth | ✅ Present | Intercepts `execve()` calls |
| `set-qemu-name-execve.patch` | qemu-execve | ✅ Present | Renames binary to `qemu-execve-{arch}` |

### Layer 2: Zig (`zig/`)
Patches for Zig incremental compilation support (qemu-zig packages).

| Patch | Source | Status | Description |
|-------|--------|--------|-------------|
| `0006-elfload.c-PROT_WRITE.patch` | Zig fork | ❌ TODO | Adds PROT_WRITE to ELF mappings for incremental linking |
| `set-qemu-name-zig.patch` | - | ❌ TODO | Renames binary to `qemu-zig-{arch}` |

## Extracting Zig Patches

The Zig patches need to be extracted from: https://codeberg.org/ziglang/qemu

```bash
# Clone Zig's QEMU fork
git clone https://codeberg.org/ziglang/qemu.git /tmp/zig-qemu
cd /tmp/zig-qemu

# Find Zig-specific commits (compare against upstream QEMU tag)
git log --oneline v10.2.1..HEAD

# Generate patches
git format-patch v10.2.1..HEAD --output-directory /path/to/patches/
```

## Applying Patches

The build script applies patches in this order:
1. **Base patches** - Applied to source via recipe `source.patches`
2. **Variant patches** - Applied during build via `CONDA_QEMU_EXTRA_PATCHES` env var

## Security Notes

- **PROT_WRITE patch**: Allows writing to `.text` segments. This has security implications
  and should only be used when running Zig-compiled incremental binaries.
- **execve patch**: Intercepts system calls. Ensure `QEMU_EXECVE` is only set when needed.
