# CoreOS Installer

This recipe is based on:
* https://github.com/coreos/coreos-installer/archive/refs/tags/v0.25.0.tar.gz
* https://github.com/coreos/coreos-installer
* https://coreos.github.io/coreos-installer/

## Overview

coreos-installer is a program to assist with installing Fedora CoreOS (FCOS) 
and Red Hat Enterprise Linux CoreOS (RHCOS). It provides a comprehensive set 
of tools for CoreOS deployment and management.

## Key Functions

**Installation**:
Install the operating system to a target disk, optionally customizing it 
with an Ignition config or first-boot kernel parameters using the 
`coreos-installer install` command.

**Image Management**:
Download and verify an operating system image for various cloud, 
virtualization, or bare metal platforms using `coreos-installer download`.

**Stream Management**:
List Fedora CoreOS images available for download using 
`coreos-installer list-stream`.

**ISO Customization**:
Embed an Ignition config in a live ISO image to customize the running system 
that boots from it using `coreos-installer iso ignition`.

**PXE Boot Support**:
Wrap an Ignition config in an initrd image that can be appended to the live 
PXE initramfs to customize the running system that boots from it using 
`coreos-installer pxe ignition`.

## Build Notes

The build uses Rust's Cargo build system with the following key features:
* Built with `--release` profile for optimized performance
* Includes the `rdcore` feature for initrd functionality
* Uses system OpenSSL libraries (dynamically linked)
* Lets zstd-sys build its own zstd copy for compatibility
* Produces two binaries: `coreos-installer` and `rdcore`
* Requires minimal build dependencies: Rust ≥1.84, C/C++ compilers, CMake, Make

This recipe is Unix-only due to the nature of CoreOS being a Linux-based 
operating system. The installer is primarily designed for bare metal, 
virtualized, and cloud deployment scenarios.

## Usage

The main binary `coreos-installer` provides the primary installation 
functionality, while `rdcore` is used within the initrd environment 
for specialized CoreOS operations. A convenience symlink `coreos-install` 
is also provided for shorter command usage.

Common usage patterns:
```bash
# Install CoreOS to a disk
coreos-installer install /dev/sda

# Download a CoreOS image
coreos-installer download -p metal -f iso

# List available streams
coreos-installer list-stream
```

## Platform Support

This package is **not available on Windows** and this is by design. Here's why:

**CoreOS is Linux-only**: CoreOS (both Fedora CoreOS and RHEL CoreOS) are 
Linux-based operating systems. The installer is specifically designed to 
install and manage Linux systems.

**Technical limitations**:
- Uses Linux-specific system calls and device nodes (`/dev/sda`, etc.)
- Requires Linux disk partitioning and filesystem tools
- Integrates with Linux boot loaders and systemd services
- Depends on Linux-specific libraries for hardware access

**Operational context**: The installer is designed to run from:
- Linux systems with direct hardware access
- Live boot environments (CoreOS live ISOs)
- Linux servers and workstations managing bare metal deployments

**Windows users** who need to work with CoreOS should use:
- Windows Subsystem for Linux (WSL)
- Linux virtual machines
- Live Linux boot media
- Linux containers or development environments
