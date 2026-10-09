import importlib.util
from pathlib import Path

import toml

modules = [
    "isaaclab",
    "isaaclab_assets",
    "isaaclab_contrib",
    "isaaclab_mimic",
    "isaaclab_rl",
    "isaaclab_tasks",
]

missing_modules = [name for name in modules if importlib.util.find_spec(name) is None]
assert not missing_modules, f"missing modules: {missing_modules}"

module_roots: dict[str, Path] = {}
for module_name in modules:
    spec = importlib.util.find_spec(module_name)
    assert spec is not None and spec.origin is not None, f"missing spec origin: {module_name}"
    module_roots[module_name] = Path(spec.origin).parent

expected_paths = {
    "isaaclab": ["config/extension.toml", "sim/__init__.py"],
    "isaaclab_assets": ["config/extension.toml", "robots/__init__.py", "data"],
    "isaaclab_contrib": ["config/extension.toml"],
    "isaaclab_mimic": ["config/extension.toml"],
    "isaaclab_rl": ["config/extension.toml"],
    "isaaclab_tasks": ["config/extension.toml", "direct/__init__.py"],
}

for module_name, rel_paths in expected_paths.items():
    module_root = module_roots[module_name]
    for rel_path in rel_paths:
        file_path = module_root / rel_path
        if rel_path == "data":
            assert file_path.is_dir(), f"missing dir {module_name}:{rel_path}"
        else:
            assert file_path.is_file(), f"missing file {module_name}:{rel_path}"

# Ensure extension metadata is readable from relocated module-local config folders.
for module_name in modules:
    extension_toml = module_roots[module_name] / "config" / "extension.toml"
    assert extension_toml.is_file(), f"missing extension metadata: {module_name}"
    metadata = toml.loads(extension_toml.read_text())
    assert metadata.get("package", {}).get("version"), f"missing package.version in {extension_toml}"

# Validate that __init__.py was patched to use module-local extension directories.
legacy_expr = 'os.path.abspath(os.path.join(os.path.dirname(__file__), "../"))'
patched_modules = ["isaaclab", "isaaclab_assets", "isaaclab_contrib", "isaaclab_tasks"]
for module_name in patched_modules:
    init_py = module_roots[module_name] / "__init__.py"
    init_text = init_py.read_text()
    assert legacy_expr not in init_text, f"legacy extension path still present in {module_name}"
