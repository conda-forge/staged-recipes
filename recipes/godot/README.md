# Godot packaging

Initial scope: the standard editor on linux-64. The editor also runs headlessly.
Export templates, .NET, and other platforms are deferred.

The build uses conda libraries for the Linux desktop stack, SDL3, FreeType,
Graphite, Brotli, JPEG, Ogg, PNG, Theora, Vorbis, WebP, PCRE2, zlib and Zstd.

Selected bundled libraries are retained for this first build:

- ENet: upstream's changes add IPv6 and DTLS.
- ICU and HarfBuzz: upstream warns about GDExtension problems with external
  copies (Godot issues #91401 and #100301).
- mbedTLS: Godot bundles 3.6.x with custom configuration; conda-forge's current
  recipe is 4.x. External 3.6.x needs separate compatibility testing.
- Embree and glslang: review upstream patches before using external copies.
- Other embedded libraries: audit remaining builtin switches and libraries
  without switches after the first successful build.

AccessKit and Speech Dispatcher support are disabled. X11, Wayland,
Vulkan, OpenGL, ALSA, PulseAudio and SDL controller input remain enabled.

Upstream enables SSE4.2 and POPCNT on x86-64. The microarchitecture build
dependency propagates the corresponding runtime requirement.

LICENSE.txt, COPYRIGHT.txt and individual third-party license/notice files
are packaged. The remaining bundling choices still need conda-forge review.

Validation:
- YAML and shell syntax can be checked locally.
- The package tests exercise headless import, GDScript, PCRE2, zlib, Zstd,
  PNG and text shaping.
- A GUI smoke test and GDExtension compatibility test are still needed.
- The initial development environment has no Pixi/rattler-build and cannot
  download from GitHub or conda-forge, so compilation must be checked in CI.

From the staged-recipes root:

    pixi exec rattler-build build -r recipes/godot/recipe.yaml -m .ci_support/linux64.yaml
