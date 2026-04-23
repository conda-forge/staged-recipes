#!/usr/bin/env python3
import io
import json
import os
import shutil
import subprocess
import tarfile
from pathlib import Path

PREFIX = Path(os.environ["PREFIX"])
SRC = Path(os.getcwd()).resolve()
PKG_NAME = os.environ.get("PKG_NAME", "voms-lsc")

# --- Single source of truth ---
VOMS_PATHS = {
    "X509_VOMS_DIR": "grid-security/vomsdir",
    "VOMS_USERCONF": "vomses",
}

def pretty(path: Path) -> str:
    path = path.resolve()
    try:
        return f"${{SRC}}/{path.relative_to(SRC)}"
    except ValueError:
        try:
            return f"${{CONDA_PREFIX}}/{path.relative_to(PREFIX)}"
        except ValueError:
            return str(path)

# --- 1. Extract RPMs into PREFIX/etc/ ---
rpms_dir = SRC / "rpms"
if rpms_dir.exists():
    for rpm in sorted(rpms_dir.glob("*.rpm")):
        print(f"[RPM] Extracting {rpm.name}")
        with open(rpm, "rb") as rpm_fh:
            proc = subprocess.run(
                ["rpm2archive", "-"],
                stdin=rpm_fh,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                check=True,
            )
        with tarfile.open(fileobj=io.BytesIO(proc.stdout), mode="r:*") as tf:
            for member in tf.getmembers():
                # Strip leading "./" so paths are relative to etc/
                member.name = member.name.lstrip("./")
                if not member.name.startswith("etc/"):
                    continue
                dst = PREFIX / member.name
                if member.isdir():
                    dst.mkdir(parents=True, exist_ok=True)
                elif member.isfile():
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    with tf.extractfile(member) as src_f, open(dst, "wb") as dst_f:
                        shutil.copyfileobj(src_f, dst_f)
                    print(f"  [FILE] {member.name}")

# --- 2. Copy etc/ tree ---
src_etc = Path("etc")
dst_etc = PREFIX / "etc"

print(f"[INFO] Copying {pretty(src_etc)} -> {pretty(dst_etc)}")
dst_etc.mkdir(parents=True, exist_ok=True)

for item in src_etc.iterdir():
    src = item
    dst = dst_etc / item.name
    print(f"[COPY] {pretty(src)} -> {pretty(dst)}")

    if item.is_dir():
        shutil.copytree(src, dst, dirs_exist_ok=True)
    else:
        shutil.copy2(src, dst)

# --- 3. Fix permissions ---
print("\n[INFO] Setting permissions (755)")

for name, rel_path in VOMS_PATHS.items():
    base = dst_etc / rel_path

    if not base.exists():
        print(f"[WARN] Missing: {pretty(base)}")
        continue

    print(f"[CHMOD] {name}: {pretty(base)}")

    for root, dirs, files in os.walk(base):
        for d in dirs:
            path = Path(root) / d
            print(f"  [DIR ] {pretty(path)} (-> 755)")
            os.chmod(path, 0o755)

        for f in files:
            path = Path(root) / f
            print(f"  [FILE] {pretty(path)} (-> 755)")
            os.chmod(path, 0o755)

    print(f"  [ROOT] {pretty(base)} (-> 755)")
    os.chmod(base, 0o755)

# --- 4. Create env_vars.d JSON ---
env_vars_dir = PREFIX / "etc" / "conda" / "env_vars.d"
env_vars_dir.mkdir(parents=True, exist_ok=True)

env_file = env_vars_dir / f"{PKG_NAME}.json"

env_contents = {
    key: str(PREFIX / "etc" / rel_path)
    for key, rel_path in VOMS_PATHS.items()
}

print(f"\n[WRITE] {pretty(env_file)}")
print(json.dumps(env_contents, indent=2))

with open(env_file, "w") as f:
    json.dump(env_contents, f, indent=2)

print("[DONE]")
