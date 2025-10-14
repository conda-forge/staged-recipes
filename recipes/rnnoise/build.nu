#!/usr/bin/env nu

if $env.target_platform? != "win-64" {
    cp ($env.BUILD_PREFIX | path join "share" "gnuconfig" "config.guess") .
    cp ($env.BUILD_PREFIX | path join "share" "gnuconfig" "config.sub") .
}

cd $env.SRC_DIR
$env.LDFLAGS = $"($env.LDFLAGS? | default "") -L($env.PREFIX)/lib -Wl,-rpath,($env.PREFIX)/lib"
if $nu.os-info.name == "Linux" {
    $env.LDFLAGS = $"($env.LDFLAGS) -lrt"
}
print "=== Copying model files from model/src/ to root ==="
# instead of ./download_model.sh
cp model/src/rnnoise_data.c .
cp model/src/rnnoise_data.h .

^autoreconf --install --symlink --force --verbose
./configure $"--prefix=($env.PREFIX)" --enable-x86-rtcd

# Apply Windows-specific patches if needed
if $env.target_platform? == "win-64" {
    ^patch_libtool
}
let cpu_count = ($env.CPU_COUNT? | default "1")
^make $"-j($cpu_count)"
