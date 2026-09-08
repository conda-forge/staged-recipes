#!/usr/bin/env bash
set -e

# SCons does not inherit conda's compiler settings automatically.
# Keep LTO off for the initial CI build to limit linker memory use.
scons -j "${CPU_COUNT}" \
    platform=linuxbsd target=editor arch=x86_64 \
    "CC=${CC}" "CXX=${CXX}" "AR=${AR}" "RANLIB=${RANLIB}" \
    "ccflags=${CPPFLAGS}" "cflags=${CFLAGS}" "cxxflags=${CXXFLAGS}" \
    "linkflags=${LDFLAGS}" \
    import_env_vars=CONDA_BUILD_SYSROOT,CONDA_PREFIX \
    use_static_cpp=no use_sowrap=no use_volk=no \
    lto=none debug_symbols=no engine_update_check=no \
    accesskit=no speechd=no \
    builtin_brotli=no builtin_freetype=no builtin_graphite=no \
    builtin_libjpeg_turbo=no builtin_libogg=no builtin_libpng=no \
    builtin_libtheora=no builtin_libvorbis=no builtin_libwebp=no \
    builtin_pcre2=no builtin_sdl=no builtin_zlib=no builtin_zstd=no

install -Dm755 bin/godot.linuxbsd.editor.x86_64 "${PREFIX}/bin/godot"
install -Dm644 misc/dist/linux/org.godotengine.Godot.desktop \
    "${PREFIX}/share/applications/org.godotengine.Godot.desktop"
install -Dm644 icon.svg "${PREFIX}/share/icons/hicolor/scalable/apps/godot.svg"

# Preserve individual notices in addition to upstream's copyright inventory.
python - <<'PY'
from pathlib import Path
import shutil

source = Path("thirdparty")
destination = Path("thirdparty-licenses")
for path in source.rglob("*"):
    if not path.is_file():
        continue
    name = path.name.lower()
    if (
        name.startswith(("license", "licence", "copying", "copyright", "notice"))
        or name in {"authors", "authors.txt", "readme.ijg", "ftl.txt"}
    ):
        target = destination / path.relative_to(source)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
PY
