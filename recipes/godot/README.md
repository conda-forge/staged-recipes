# Godot packaging

Scope: the standard editor on linux-64 and win-64. The editor also runs
headlessly. Export templates, .NET, and other platforms are deferred.

The build uses Brush and keeps the build script inline in `recipe.yaml`.
Conda libraries replace bundled copies of Brotli, Graphite2, JPEG, Ogg, PNG,
Theora, Vorbis, WebP, PCRE2, SDL3, zlib, and Zstd on both platforms. The
Windows build also uses conda's Embree, glslang, MSDFgen, SPIR-V Tools, and
Vulkan loader. Linux additionally uses conda's FreeType and desktop stack.

The Windows Direct3D 12 driver builds Godot's pinned Mesa/NIR fork from source.
It uses the D3D12 runtime supplied by Windows rather than packaging Microsoft's
binary Agility SDK.

Menuinst metadata adds desktop launchers on Windows and Linux.

Selected bundled libraries remain:

- ENet: upstream's changes add IPv6 and DTLS.
- ICU and HarfBuzz: upstream warns about GDExtension problems with external
  copies (Godot issues #91401 and #100301).
- mbedTLS: Godot bundles 3.6.x with custom configuration; conda-forge's current
  recipe is 4.x.
- FreeType on Windows: conda-forge's Windows build cannot load Godot's embedded
  WOFF2 fallback font. The bundled copy uses external Brotli and preserves
  editor text rendering.
- Libraries without a supported system-library switch remain embedded.

AccessKit is disabled on both platforms, and Speech Dispatcher is disabled on
Linux. X11, Wayland, Vulkan, OpenGL, Direct3D 12, ALSA, PulseAudio, and SDL
controller input remain enabled where supported. ANGLE is disabled on Windows
because its upstream build path requires separate prebuilt artifacts.

Upstream enables SSE4.2 and POPCNT on Linux x86-64. The microarchitecture build
dependency propagates the corresponding runtime requirement.

`LICENSE.txt`, `COPYRIGHT.txt`, individual Godot third-party notices, and the
licenses for the statically linked Mesa/NIR source are packaged.

The Windows build and package tests pass locally, including version and help
commands plus headless regex, compression, PNG, and fallback-font shaping
checks. The D3D12 editor path also starts successfully on an AMD Radeon RX 7800
XT using feature level 12_0 and the Forward+ renderer:

    pixi exec rattler-build build -r recipes/godot/recipe.yaml -m .ci_support/win64.yaml

Use the Linux variant for the existing Linux build:

    pixi exec rattler-build build -r recipes/godot/recipe.yaml -m .ci_support/linux64.yaml
