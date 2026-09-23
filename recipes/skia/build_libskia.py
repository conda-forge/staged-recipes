"""Configure, build and install libskia.

Skia has no install target, so we place the library, the public headers and a
pkg-config file ourselves. Headers go to $PREFIX/include/skia/include/... because
Skia's own headers include each other as "include/core/SkFoo.h", relative to the
source root; skia.pc therefore points at $PREFIX/include/skia.
"""

import os
import shutil
import subprocess
import sys

# Keep in sync with the defines that BUILD.gn's config("skia_public") adds for
# the GN arguments we pass below. Anything in that config is part of the public
# ABI and has to be visible to consumers too, so we write it into
# include/config/SkUserConfig.h before configuring. That header is included by
# every public Skia header (via SkLoadUserConfig.h) and is the documented port
# point, so the library and its consumers cannot end up disagreeing.
PUBLIC_DEFINES = [
    "SK_CODEC_DECODES_BMP",
    "SK_CODEC_DECODES_WBMP",
    "SK_HIDE_PATH_EDIT_METHODS",
    # we always build a shared library, so SK_API has to expand to dllimport /
    # default visibility for consumers
    "SKIA_DLL",
]
if sys.platform.startswith("linux"):
    # skia_public makes kN32_SkColorType BGRA on Linux; this one changes the
    # meaning of pixel data, so it really must not drift between us and consumers
    PUBLIC_DEFINES.append("SK_R32_SHIFT=16")

# Matches skia-builder's SKIA_BUILD_ARGS, which is the configuration skia-pathops
# has been shipping: no GPU backends, no codecs, no text shaping, no system
# libraries. Keeping the surface this small is what lets us build without any of
# Skia's third_party/externals checkout.
GN_ARGS = [
    "is_official_build=true",
    "is_debug=false",
    # ship a shared library rather than the static archive skia-builder produces,
    # so consumers do not each bake their own copy of Skia into their binaries
    "is_component_build=true",
    "skia_enable_pdf=false",
    "skia_enable_discrete_gpu=false",
    "skia_enable_ganesh=false",
    "skia_enable_skottie=false",
    "skia_enable_skshaper=false",
    "skia_use_dng_sdk=false",
    "skia_use_expat=false",
    "skia_use_freetype=false",
    "skia_use_fontconfig=false",
    "skia_use_fonthost_mac=false",
    "skia_use_gl=false",
    "skia_use_harfbuzz=false",
    "skia_use_icu=false",
    "skia_use_libjpeg_turbo_encode=false",
    "skia_use_libjpeg_turbo_decode=false",
    "skia_use_libpng_encode=false",
    "skia_use_libpng_decode=false",
    "skia_use_libwebp_encode=false",
    "skia_use_libwebp_decode=false",
    "skia_use_piex=false",
    "skia_use_xps=false",
    "skia_use_zlib=false",
    "skia_enable_spirv_validation=false",
    "skia_use_lua=false",
    "skia_use_wuffs=false",
    'extra_cflags=["-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER"]',
]

# conda target_platform -> GN target_cpu
TARGET_CPU = {
    "linux-64": "x64",
    "linux-aarch64": "arm64",
    "linux-ppc64le": "ppc64",
    "osx-64": "x64",
    "osx-arm64": "arm64",
    "win-64": "x64",
}

PKG_CONFIG_TEMPLATE = """\
prefix=${{pcfiledir}}/../..
includedir=${{prefix}}/include/skia
libdir=${{prefix}}/lib

Name: skia
Description: 2D graphics library
URL: https://skia.org
Version: {version}
Libs: -L${{libdir}} -lskia
Cflags: -I${{includedir}}
"""


def write_user_config(src_dir):
    """Bake the public defines into the header every Skia consumer picks up."""
    path = os.path.join(src_dir, "include", "config", "SkUserConfig.h")
    with open(path) as f:
        contents = f.read()

    block = ["", "// --- added by conda-forge ---"]
    for define in PUBLIC_DEFINES:
        name, _, value = define.partition("=")
        block += [
            "#ifndef " + name,
            "#define " + name + (" " + value if value else ""),
            "#endif",
        ]
    block += ["// --- end conda-forge ---", ""]

    # the file ends with the #endif of its own include guard, so splice ahead of it
    head, sep, tail = contents.rpartition("#endif")
    assert sep, "could not find include guard in " + path
    with open(path, "w") as f:
        f.write(head + "\n".join(block) + sep + tail)


def gn_args():
    args = list(GN_ARGS)

    target_platform = os.environ["target_platform"]
    target_cpu = TARGET_CPU.get(target_platform)
    if target_cpu is None:
        sys.exit("unsupported target_platform: " + target_platform)
    args.append('target_cpu="%s"' % target_cpu)

    if sys.platform != "win32":
        # on Windows an empty font manager collides with SkFontMgr_win_dw_factory
        args.append("skia_enable_fontmgr_empty=true")
        # GN does not look at CC/CXX/AR, so hand it the conda compilers. This is
        # also what makes cross-compiling work: the conda cross compiler already
        # targets the right triple.
        for var in ("CC", "CXX", "AR"):
            value = os.environ.get(var)
            if value:
                args.append('%s="%s"' % (var.lower(), value))

    return args


def install(src_dir, build_dir, prefix, version):
    dst_include = os.path.join(prefix, "include", "skia", "include")
    if os.path.isdir(dst_include):
        shutil.rmtree(dst_include)
    os.makedirs(os.path.dirname(dst_include), exist_ok=True)
    shutil.copytree(
        os.path.join(src_dir, "include"),
        dst_include,
        ignore=shutil.ignore_patterns("BUILD.bazel", "*.gni", "WORKSPACE*"),
    )

    lib_dir = os.path.join(prefix, "lib")
    os.makedirs(lib_dir, exist_ok=True)

    if sys.platform == "win32":
        bin_dir = os.path.join(prefix, "bin")
        os.makedirs(bin_dir, exist_ok=True)
        shutil.copy(os.path.join(build_dir, "skia.dll"), bin_dir)
        # gn names the import library skia.dll.lib; consumers expect skia.lib
        shutil.copy(
            os.path.join(build_dir, "skia.dll.lib"), os.path.join(lib_dir, "skia.lib")
        )
    else:
        libname = "libskia" + (".dylib" if sys.platform == "darwin" else ".so")
        shutil.copy(os.path.join(build_dir, libname), lib_dir)

    pkgconfig_dir = os.path.join(lib_dir, "pkgconfig")
    os.makedirs(pkgconfig_dir, exist_ok=True)
    with open(os.path.join(pkgconfig_dir, "skia.pc"), "w") as f:
        f.write(PKG_CONFIG_TEMPLATE.format(version=version))


def main():
    src_dir = os.environ.get("SRC_DIR", os.getcwd())
    prefix = os.environ.get("LIBRARY_PREFIX") or os.environ["PREFIX"]
    version = os.environ["PKG_VERSION"]
    build_dir = os.path.join(src_dir, "out", "Release")

    write_user_config(src_dir)

    gn = shutil.which("gn")
    if gn is None:
        sys.exit("could not find gn")

    subprocess.check_call(
        [
            gn,
            "gen",
            build_dir,
            # .gn hardcodes python3, which conda environments do not ship on
            # Windows; point GN at the interpreter running this script instead
            "--script-executable=" + sys.executable,
            "--args=" + " ".join(gn_args()),
        ],
        cwd=src_dir,
    )

    ninja = ["ninja", "-C", build_dir, "skia"]
    cpu_count = os.environ.get("CPU_COUNT")
    if cpu_count:
        ninja[1:1] = ["-j", cpu_count]
    subprocess.check_call(ninja, cwd=src_dir)

    install(src_dir, build_dir, prefix, version)


if __name__ == "__main__":
    main()
