# distrobuilder

Image building tool for [LXC](https://linuxcontainers.org/lxc/) and
[Incus](https://linuxcontainers.org/incus/) containers.

## Linux only

This recipe builds only on Linux. Windows and macOS are skipped.

Distrobuilder depends on Linux-specific syscalls 
(`mount`, `MS_BIND`, `MNT_DETACH`, `MemfdCreate` via `golang.org/x/sys/unix`) 
and Linux userspace tools (`debootstrap`, `squashfs-tools`, `qemu-kvm`) 
that have no equivalents on other platforms. 
The upstream project does not support Windows or macOS.

## Upstream vs. conda-forge build

### Upstream (Makefile)

The upstream project builds with `make` which internally calls:

```
go install -v ./...
```

This compiles and installs all packages in the repository using the default Go install path.
It relies on `go install` to place the binary in `$GOBIN` or `$GOPATH/bin`.

### conda-forge recipe

The conda-forge recipe imitates 
https://github.com/conda-forge/conda-forge.github.io/blob/main/docs/maintainer/example_recipes/go.md
which builds with:

```
go build -v -o $PREFIX/bin/distrobuilder -ldflags="-s -w" ./distrobuilder
```

And extracts license files using `go-licenses`.

Key differences:

- **Explicit package path** (`./distrobuilder`): The `main` package lives
  in the `distrobuilder/` subdirectory, not at the repo root. The upstream
  `go install ./...` discovers it automatically; the recipe targets it
  directly.
- **Explicit output path** (`-o $PREFIX/bin/distrobuilder`): Places the
  binary into the conda prefix rather than relying on `$GOBIN`.
- **Strip flags** (`-ldflags="-s -w"`): Strips the symbol table (`-s`) and
  DWARF debug info (`-w`) to reduce binary size. The upstream Makefile does
  not apply these.
- **`go build` vs. `go install`**: The recipe uses `go build` for direct
  control over the output location, whereas upstream uses `go install`.
- **License collection**: The recipe runs `go-licenses save ./distrobuilder`
  to collect third-party license texts, which upstream does not do as part
  of its build.

### CGO

Distrobuilder uses CGO in `distrobuilder/main.go` to call Linux kernel
interfaces (`sched.h`, `mount.h`, `unistd.h`, etc.) via glibc. 
No additional C library packages are required beyond the C standard library
provided by the `${{ stdlib('c') }}` dependency.

The `lxc/incus/v6/shared/util` Go dependency is pure Go and does not
introduce any further CGO requirements.

### License collection

The recipe uses `go-licenses save` to collect third-party license texts
into a `library_licenses/` directory, which is included in the package
alongside the project's own `COPYING` file.

Two modules are excluded from `go-licenses save` via `--ignore`:

- **`github.com/lxc/distrobuilder`** — The project itself. Its license
  (`COPYING`, Apache-2.0) is already included directly as `src/COPYING`.
- **`github.com/rootless-containers/proto/go-proto`** — This module is
  Apache-2.0, but its license is stored in a file named `COPYING` rather
  than `LICENSE`. `go-licenses` does not recognize this naming convention
  and reports the license as "unknown", causing a fatal error. The module's
  license can be verified at
  https://github.com/rootless-containers/proto/blob/main/COPYING.
