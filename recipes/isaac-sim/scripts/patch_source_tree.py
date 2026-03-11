from __future__ import annotations

import re
from pathlib import Path


def replace_block(text: str, old: str, new: str, description: str) -> str:
    if old in text:
        return text.replace(old, new)
    if new in text:
        return text
    raise SystemExit(f"Could not find the expected {description} block")


def drop_regex(path: Path, pattern: str) -> None:
    text = path.read_text()
    updated, count = re.subn(pattern, "", text, flags=re.MULTILINE | re.DOTALL)
    if count:
        path.write_text(updated)


def patch_repo_toml(root: Path) -> None:
    repo_toml = root / "repo.toml"
    text = repo_toml.read_text()

    text = replace_block(
        text,
        """fetch.pip.files_to_pull = [
  "${root}/deps/pip.toml",
  "${root}/deps/pip_ml.toml",
  "${root}/deps/pip_lula.toml",
  "${root}/deps/pip_compute.toml",
  "${root}/deps/pip_usd_to_urdf.toml",
  "${root}/deps/pip_cloud.toml",
]""",
        """fetch.pip.files_to_pull = [
  "${root}/deps/pip_lula.toml",
]""",
        "fetch.pip.files_to_pull",
    )

    text = replace_block(
        text,
        """enable_compiler_version_check = true

"platform:linux-x86_64".version_check_gcc_version = "11.*.*"
"platform:linux-aarch64".version_check_gcc_version = "11.*.*"
""",
        "enable_compiler_version_check = false\n",
        "enable_compiler_version_check",
    )

    text = replace_block(
        text,
        """[repo_kit_pull_extensions]
precache_exts_enabled = false
""",
        """[repo_kit_pull_extensions]
precache_exts_enabled = false
""",
        "repo_kit_pull_extensions",
    )

    text = replace_block(
        text,
        """apps = [
    "${root}/_build/$platform/$config/apps/isaacsim.exp.extscache.kit"
]""",
        """apps = [
    "${root}/source/apps/conda.extscache.kit"
]""",
        "repo_precache_exts.apps",
    )

    text = replace_block(
        text,
        """links.exts.include = [
  "omni.usd.core",
  "omni.syntheticdata",
  "usdrt.scenegraph",
  "omni.graph.tools",
  "omni.kit.test",
  "isaacsim.util.debug_draw",
  "omni.kit.asset_converter"
]""",
        """links.exts.include = [
  "omni.usd.core",
  "usdrt.scenegraph",
  "omni.graph.tools",
  "isaacsim.util.debug_draw",
  "omni.kit.asset_converter"
]""",
        "repo_precache_exts.links.exts.include",
    )

    text = replace_block(
        text,
        """pre_build.commands = [
  [
    "${root}/repo${shell_ext}",
    "precache_exts",
    "-c",
    "${config}",
    "${precache_flag_0}",
  ],
]""",
        """pre_build.commands = [
  [
    "${root}/repair_packman_python.sh",
  ],
  [
    "${root}/stage_local_extscache.sh",
  ],
]""",
        "pre_build.commands",
    )

    text = text.replace(
        """  [
    "${root}/repo${shell_ext}",
    "usd",
    "-c",
    "${config}",
  ],
""",
        "",
    )

    text = replace_block(
        text,
        """[repo_precache_exts]
generated_app_path = ""
enabled = true
kit_omit_ext_version = false
# Extra args to pass to kit
kit_extra_args = []
""",
        """[repo_precache_exts]
generated_app_path = ""
enabled = false
kit_omit_ext_version = false
# Extra args to pass to kit
kit_extra_args = []
""",
        "repo_precache_exts.enabled",
    )

    repo_toml.write_text(text)


def patch_packman_manifests(root: Path) -> None:
    kit_sdk_deps = root / "deps" / "kit-sdk-deps.packman.xml"
    for name in ("pybind11", "python", "fmt", "nvtx", "gsl", "doctest", "cuda"):
        drop_regex(kit_sdk_deps, rf'^\s*<filter include="{re.escape(name)}" />\n')
        drop_regex(kit_sdk_deps, rf'^\s*<dependency name="{re.escape(name)}" linkPath="[^"]+" />\n')

    drop_regex(
        kit_sdk_deps,
        r"\n\s*<import path=\"\.\./_build/target-deps/omni_physics/\$\{config\}/deps/schema-deps\.packman\.xml\">\n"
        r"\s*<filter include=\"usd_ext_physics_\$\{config\}\" />\n"
        r"\s*</import>\n",
    )
    drop_regex(kit_sdk_deps, r'^\s*<filter include="usd_ext_physics_\$\{config\}" />\n')
    drop_regex(
        kit_sdk_deps,
        r'\s*<dependency name="usd_ext_physics_\$\{config\}" linkPath="\.\./_build/target-deps/usd_ext_physics/\$\{config\}" />',
    )

    drop_regex(
        kit_sdk_deps,
        r"\n\s*<!-- The doctest package imported from kit-kernel is not yet available\. -->\n"
        r"\s*<dependency name=\"doctest\" linkPath=\"[^\"]+\">\n"
        r"\s*<package name=\"doctest\" version=\"[^\"]+\" />\n"
        r"\s*</dependency>\n",
    )

    isaac_packman = root / "deps" / "isaac-sim.packman.xml"
    for name in ("octomap", "tinyxml2", "nlohmann_json", "rapidjson", "lula", "nv_ros2_humble", "nv_ros2_jazzy"):
        drop_regex(
            isaac_packman,
            rf'\s*<dependency name="{re.escape(name)}" linkPath="[^"]+">.*?</dependency>',
        )


def patch_python_dependency_manifests(root: Path) -> None:
    pip_lula = root / "deps" / "pip_lula.toml"
    text = pip_lula.read_text()
    text = text.replace(
        'extra_args = ["--no-index", "-f", "../_build/target-deps/lula/pip-packages"]',
        'extra_args = ["--no-index", "-f", "_build/target-deps/lula/pip-packages"]',
    )
    pip_lula.write_text(text)


def replace_text(path: Path, old: str, new: str, description: str) -> None:
    text = path.read_text()
    updated = replace_block(text, old, new, description)
    if updated != text:
        path.write_text(updated)


def remove_lines(path: Path, patterns: tuple[str, ...]) -> None:
    text = path.read_text()
    original = text
    for pattern in patterns:
        text = re.sub(pattern, "", text, flags=re.MULTILINE)
    if text != original:
        path.write_text(text)


def disable_extension_build(path: Path, reason: str) -> None:
    path.write_text(f"-- {reason}\n")


def patch_app_manifests(root: Path) -> None:
    full_app = root / "source" / "apps" / "isaacsim.exp.full.kit"
    text = full_app.read_text()
    text = re.sub(
        r'^exts\."isaacsim\.ros2\.bridge"\.ros_distro = "system_default"\n',
        "",
        text,
        flags=re.MULTILINE,
    )
    text = re.sub(
        r'^(isaac\.startup\.ros_bridge_extension = )"isaacsim\.ros2\.bridge"$',
        r'\1""',
        text,
        flags=re.MULTILINE,
    )
    full_app.write_text(text)

    zero_delay_app = root / "source" / "apps" / "isaacsim.exp.base.zero_delay.kit"
    remove_lines(
        zero_delay_app,
        (r'^app\.exts\.isaacsim\.ros2\.bridge\.publish_multithreading_disabled = true.*\n',),
    )


def disable_ros2_extensions(root: Path) -> None:
    disable_extension_build(
        root / "source" / "extensions" / "isaacsim.ros2.bridge" / "premake5.lua",
        "Disabled for conda-forge: ROS2 bridge requires externally bundled ROS2 vendor payloads.",
    )
    disable_extension_build(
        root / "source" / "extensions" / "isaacsim.ros2.tf_viewer" / "premake5.lua",
        "Disabled for conda-forge: ROS2 TF viewer depends on the ROS2 bridge vendor payloads.",
    )


def disable_unbuildable_tests(root: Path) -> None:
    drop_regex(
        root / "source" / "extensions" / "isaacsim.core.includes" / "premake5.lua",
        r"\n-- -------------------------------------\n"
        r"-- Build the C\+\+ plugin that will be loaded by the tests\n"
        r'project_ext_tests\(ext, "isaacsim\.core\.includes\.tests"\).*?'
        r"filter \{\}\n\n",
    )
    drop_regex(
        root / "source" / "extensions" / "isaacsim.ros2.bridge" / "premake5.lua",
        r"\n-- Build the C\+\+ plugin that will be loaded by the tests\n"
        r'project_ext_tests\(ext, "isaacsim\.ros2\.bridge\.backend_tests"\).*?'
        r"filter \{\}\n",
    )

    core_includes_config = root / "source" / "extensions" / "isaacsim.core.includes" / "config" / "extension.toml"
    core_includes_config.write_text(
        replace_block(
            core_includes_config.read_text(),
            """[[test]]
enabled = true
dependencies = [
    "omni.kit.test",
]
cppTests.libraries = [
    "bin/${lib_prefix}isaacsim.core.includes.tests${lib_ext}",
]
""",
            """[[test]]
enabled = false
dependencies = [
    "omni.kit.test",
]
cppTests.libraries = [
    "bin/${lib_prefix}isaacsim.core.includes.tests${lib_ext}",
]
""",
            "isaacsim.core.includes test",
        )
    )

    ros2_bridge_config = root / "source" / "extensions" / "isaacsim.ros2.bridge" / "config" / "extension.toml"
    ros2_bridge_config.write_text(
        replace_block(
            ros2_bridge_config.read_text(),
            """[[test]]
name = "doctest"
enabled = true
""",
            """[[test]]
name = "doctest"
enabled = false
""",
            "isaacsim.ros2.bridge doctest",
        )
    )


def patch_platform_headers(root: Path) -> None:
    platform_header = (
        root
        / "source"
        / "extensions"
        / "isaacsim.core.includes"
        / "include"
        / "isaacsim"
        / "core"
        / "includes"
        / "core"
        / "Platform.h"
    )
    text = platform_header.read_text()
    if "#include <cstdint>" not in text:
        platform_header.write_text(
            text.replace("#    include <unistd.h>\n", "#    include <unistd.h>\n#    include <cstdint>\n")
        )


def write_extscache_app(root: Path) -> None:
    app_dir = root / "source" / "apps"
    app_dir.mkdir(parents=True, exist_ok=True)
    (app_dir / "conda.extscache.kit").write_text(
        """[settings.app.exts]
folders = [
    "${app}/../exts",
    "${app}",
    "${app}/../extsDeprecated",
]

[dependencies]
"omni.usd.core" = {}
"usdrt.scenegraph" = {}
"omni.graph.tools" = {}
"isaacsim.util.debug_draw" = {}
"omni.kit.asset_converter" = {}
"""
    )


def main() -> None:
    root = Path.cwd()
    patch_repo_toml(root)
    patch_packman_manifests(root)
    patch_python_dependency_manifests(root)
    patch_app_manifests(root)
    disable_ros2_extensions(root)
    disable_unbuildable_tests(root)
    patch_platform_headers(root)
    write_extscache_app(root)


if __name__ == "__main__":
    main()
