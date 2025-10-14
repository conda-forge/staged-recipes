#!/usr/bin/env nu

if $env.target_platform? != "win-64" {
    cp ($env.BUILD_PREFIX | path join "share" "gnuconfig" "config.guess") .
    cp ($env.BUILD_PREFIX | path join "share" "gnuconfig" "config.sub") .
}

cd $env.SRC_DIR
let base_ldflags = $"($env.LDFLAGS? | default "") -L($env.PREFIX)/lib -Wl,-rpath,($env.PREFIX)/lib"
$env.LDFLAGS = match $nu.os-info.name {
    "linux" | "Linux" => $"($base_ldflags) -lrt"
    "macos" | "macOS" | "darwin" | "Darwin" => $base_ldflags
    "windows" | "Windows" => $base_ldflags
    _ => $base_ldflags
}
# Model files are now extracted directly to src/ directory
# (no need to copy since target_directory was removed from recipe.yaml)
# instead of ./download_model.sh

^autoreconf --install --symlink --force --verbose
./configure $"--prefix=($env.PREFIX)" --enable-x86-rtcd

# Apply Windows-specific patches if needed
if $env.target_platform? == "win-64" {
    ^patch_libtool
}
let cpu_count = ($env.CPU_COUNT? | default "1")
^make $"-j($cpu_count)"
^make install
