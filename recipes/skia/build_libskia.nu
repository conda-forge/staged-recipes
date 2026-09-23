# Configure, build and install libskia.
#
# Skia has no install target, so we place the library, the public headers and a
# pkg-config file ourselves. Headers go to $PREFIX/include/skia/include/... because
# Skia's own headers include each other as "include/core/SkFoo.h", relative to the
# source root; skia.pc therefore points at $PREFIX/include/skia.
#
# One script covers every platform, so the Windows and unix paths cannot drift.

# Keep in sync with the defines that BUILD.gn's config("skia_public") adds for
# the GN arguments we pass below. Anything in that config is part of the public
# ABI and has to be visible to consumers too, so we write it into
# include/config/SkUserConfig.h before configuring. That header is included by
# every public Skia header (via SkLoadUserConfig.h) and is the documented port
# point, so the library and its consumers cannot end up disagreeing.
const PUBLIC_DEFINES = [
    "SK_CODEC_DECODES_BMP"
    "SK_CODEC_DECODES_WBMP"
    "SK_HIDE_PATH_EDIT_METHODS"
    # we always build a shared library, so SK_API has to expand to dllimport /
    # default visibility for consumers
    "SKIA_DLL"
]

# skia_public makes kN32_SkColorType BGRA on Linux; this one changes the meaning
# of pixel data, so it really must not drift between us and consumers.
const LINUX_PUBLIC_DEFINES = ["SK_R32_SHIFT=16"]

# Matches skia-builder's SKIA_BUILD_ARGS, which is the configuration skia-pathops
# has been shipping: no GPU backends, no codecs, no text shaping, no system
# libraries. Keeping the surface this small is what lets us build without any of
# Skia's third_party/externals checkout.
const GN_ARGS = [
    "is_official_build=true"
    "is_debug=false"
    # ship a shared library rather than the static archive skia-builder produces,
    # so consumers do not each bake their own copy of Skia into their binaries
    "is_component_build=true"
    "skia_enable_pdf=false"
    "skia_enable_discrete_gpu=false"
    "skia_enable_ganesh=false"
    "skia_enable_skottie=false"
    "skia_enable_skshaper=false"
    "skia_use_dng_sdk=false"
    "skia_use_expat=false"
    "skia_use_freetype=false"
    "skia_use_fontconfig=false"
    "skia_use_fonthost_mac=false"
    "skia_use_gl=false"
    "skia_use_harfbuzz=false"
    "skia_use_icu=false"
    "skia_use_libjpeg_turbo_encode=false"
    "skia_use_libjpeg_turbo_decode=false"
    "skia_use_libpng_encode=false"
    "skia_use_libpng_decode=false"
    "skia_use_libwebp_encode=false"
    "skia_use_libwebp_decode=false"
    "skia_use_piex=false"
    "skia_use_xps=false"
    "skia_use_zlib=false"
    "skia_enable_spirv_validation=false"
    "skia_use_lua=false"
    "skia_use_wuffs=false"
    'extra_cflags=["-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER"]'
]

# conda target_platform -> GN target_cpu
const TARGET_CPU = {
    linux-64: "x64"
    linux-aarch64: "arm64"
    linux-ppc64le: "ppc64"
    osx-64: "x64"
    osx-arm64: "arm64"
    win-64: "x64"
}

# kept literal so nushell interpolation never touches pkg-config's own ${...}
const PKG_CONFIG_TEMPLATE = 'prefix=${pcfiledir}/../..
includedir=${prefix}/include/skia
libdir=${prefix}/lib

Name: skia
Description: 2D graphics library
URL: https://skia.org
Version: @VERSION@
Libs: -L${libdir} -lskia
Cflags: -I${includedir}
'

def public-defines []: nothing -> list<string> {
    if $nu.os-info.name == "linux" {
        $PUBLIC_DEFINES | append $LINUX_PUBLIC_DEFINES
    } else {
        $PUBLIC_DEFINES
    }
}

# Bake the public defines into the header every Skia consumer picks up.
def write-user-config [src_dir: string] {
    let path = ($src_dir | path join "include" "config" "SkUserConfig.h")
    let contents = (open --raw $path | decode utf-8)

    let body = (public-defines | each {|define|
        let parts = ($define | split row "=")
        let name = ($parts | first)
        let value = ($parts | skip 1 | str join "=")
        let set = if ($value | is-empty) { $"#define ($name)" } else { $"#define ($name) ($value)" }
        [$"#ifndef ($name)" $set "#endif"]
    } | flatten)

    let block = (["" "// --- added by conda-forge ---"] | append $body
        | append ["// --- end conda-forge ---" ""] | str join "\n")

    # the file ends with the #endif of its own include guard, so splice ahead of it
    let guard = ($contents | str index-of --end "#endif")
    if $guard < 0 {
        error make {msg: $"could not find include guard in ($path)"}
    }
    let head = ($contents | str substring 0..<$guard)
    let tail = ($contents | str substring $guard..)

    $"($head)($block)($tail)" | save --raw --force $path
}

def gn-args []: nothing -> list<string> {
    let target_platform = $env.target_platform
    if $target_platform not-in $TARGET_CPU {
        error make {msg: $"unsupported target_platform: ($target_platform)"}
    }
    let base = ($GN_ARGS | append $'target_cpu="($TARGET_CPU | get $target_platform)"')

    if $nu.os-info.name == "windows" {
        return $base
    }

    # on Windows an empty font manager collides with SkFontMgr_win_dw_factory
    # GN does not look at CC/CXX/AR, so hand it the conda compilers. This is also
    # what makes cross-compiling work: the conda cross compiler already targets
    # the right triple.
    let compilers = ([[env, arg]; [CC, cc] [CXX, cxx] [AR, ar]] | each {|it|
        let value = ($env | get --optional $it.env | default "")
        if ($value | is-empty) { null } else { $'($it.arg)="($value)"' }
    })

    $base | append "skia_enable_fontmgr_empty=true" | append $compilers
}

def install [src_dir: string, build_dir: string, prefix: string, version: string] {
    let dst_include = ($prefix | path join "include" "skia" "include")
    if ($dst_include | path exists) { rm --recursive --force $dst_include }
    mkdir ($dst_include | path dirname)
    cp --recursive ($src_dir | path join "include") $dst_include
    # glob cannot parse a Windows drive prefix ("D:\..." and "D:/..." both fail), so
    # match relative to the directory rather than embedding the absolute path. cd is
    # scoped to the do block; glob still yields absolute paths, so rm works.
    do {
        cd $dst_include
        glob "**/{BUILD.bazel,*.gni,WORKSPACE*}" | each {|f| rm --force $f }
    }

    let lib_dir = ($prefix | path join "lib")
    mkdir $lib_dir

    if $nu.os-info.name == "windows" {
        let bin_dir = ($prefix | path join "bin")
        mkdir $bin_dir
        cp ($build_dir | path join "skia.dll") $bin_dir
        # gn names the import library skia.dll.lib; consumers expect skia.lib
        cp ($build_dir | path join "skia.dll.lib") ($lib_dir | path join "skia.lib")
    } else {
        let ext = if $nu.os-info.name == "macos" { "dylib" } else { "so" }
        cp ($build_dir | path join $"libskia.($ext)") $lib_dir
    }

    let pkgconfig_dir = ($lib_dir | path join "pkgconfig")
    mkdir $pkgconfig_dir
    $PKG_CONFIG_TEMPLATE | str replace "@VERSION@" $version
        | save --raw --force ($pkgconfig_dir | path join "skia.pc")
}

def main [] {
    let src_dir = ($env.SRC_DIR? | default $env.PWD)
    let prefix = ($env.LIBRARY_PREFIX? | default "" | if ($in | is-empty) { $env.PREFIX } else { $in })
    let version = $env.PKG_VERSION
    let build_dir = ($src_dir | path join "out" "Release")

    cd $src_dir
    write-user-config $src_dir

    let gn = (which gn | get --optional path.0)
    if ($gn | is-empty) { error make {msg: "could not find gn"} }

    # .gn hardcodes python3, which conda environments do not ship on Windows;
    # point GN at the python from the build environment instead
    let python = (which python | get --optional path.0)
    if ($python | is-empty) { error make {msg: "could not find python"} }

    ^$gn gen $build_dir $"--script-executable=($python)" $"--args=(gn-args | str join ' ')"

    let jobs = ($env.CPU_COUNT? | default "")
    let ninja_args = (if ($jobs | is-empty) { [] } else { ["-j" $jobs] })
    ^ninja ...$ninja_args -C $build_dir skia

    install $src_dir $build_dir $prefix $version
}
