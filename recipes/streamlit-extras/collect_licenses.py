"""Collect licenses of the npm packages bundled into the frontend JS builds.

Runs after the wheel build, when each frontend still has its node_modules.
Writes ThirdPartyLicenses.txt in the source root.
"""
import json
import shutil
import subprocess
from pathlib import Path

LICENSE_GLOBS = ("LICEN[CS]E*", "licen[cs]e*", "COPYING*", "NOTICE*")

npm = shutil.which("npm") or "npm"
packages = {}

for frontend in sorted(Path("src/streamlit_extras").glob("*/frontend")):
    if not (frontend / "node_modules").is_dir():
        continue
    out = subprocess.run(
        [npm, "ls", "--omit=dev", "--all", "--parseable"],
        cwd=frontend, check=True, capture_output=True, text=True,
    ).stdout
    for line in out.splitlines()[1:]:  # first line is the frontend itself
        pkg_dir = Path(line.strip())
        meta = json.loads((pkg_dir / "package.json").read_text(encoding="utf-8"))
        key = f"{meta['name']}@{meta['version']}"
        if key in packages:
            continue
        texts = []
        for pattern in LICENSE_GLOBS:
            for f in sorted(pkg_dir.glob(pattern)):
                if f.is_file() and f.name not in [t[0] for t in texts]:
                    texts.append((f.name, f.read_text(encoding="utf-8", errors="replace")))
        packages[key] = (meta.get("license", "UNKNOWN"), texts)

missing = [k for k, (_, texts) in packages.items() if not texts]
with open("ThirdPartyLicenses.txt", "w", encoding="utf-8") as fh:
    fh.write("Licenses of npm packages bundled in the streamlit-extras frontends\n\n")
    for key in sorted(packages):
        spdx, texts = packages[key]
        fh.write("=" * 78 + f"\n{key}  ({spdx})\n" + "=" * 78 + "\n")
        for _, text in texts:
            fh.write(text.rstrip() + "\n\n")
        if not texts:
            fh.write(f"No license file shipped; package.json declares: {spdx}\n\n")

print(f"Collected licenses for {len(packages)} npm packages ({len(missing)} without a license file)")
if not packages:
    raise SystemExit("no npm packages found; were the frontends built?")
