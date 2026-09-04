import os
import sys
from pathlib import Path

def _ensure_user_dirs():
    home = Path(os.environ.get("HOME", str(Path.home())))
    xdg_data = Path(os.environ.get("XDG_DATA_HOME", home / ".local" / "share"))
    xdg_state = Path(os.environ.get("XDG_STATE_HOME", home / ".local" / "state"))
    xdg_cache = Path(os.environ.get("XDG_CACHE_HOME", home / ".cache"))

    data_dir = Path(os.environ.get("PGADMIN_DATA_DIR") or (xdg_data / "pgadmin4"))
    state_dir = Path(os.environ.get("PGADMIN_STATE_DIR") or (xdg_state / "pgadmin4"))
    cache_dir = Path(os.environ.get("PGADMIN_CACHE_DIR") or (xdg_cache / "pgadmin4"))

    for d in (data_dir, state_dir, cache_dir):
        d.mkdir(parents=True, exist_ok=True)
        try:
            d.chmod(0o700)
        except Exception:
            # On Windows or restricted contexts, chmod may fail; ignore.
            pass

    # If a config distro file hasn't been provided, create one per-user
    if not os.environ.get("CONFIG_DISTRO_FILE_PATH"):
        cfg_path = state_dir / "config_distro.py"
        if not cfg_path.exists():
            cfg_path.write_text(f"DATA_DIR = r'''{str(data_dir)}'''\n", encoding="utf-8")
        os.environ["CONFIG_DISTRO_FILE_PATH"] = str(cfg_path)

    # Export PGADMIN_CONFIG_* compatibility env vars (container convention).
    os.environ.setdefault("PGADMIN_CONFIG_DATA_DIR", str(data_dir))
    os.environ.setdefault("PGADMIN_CONFIG_LOG_FILE", str(data_dir / "pgadmin4.log"))
    os.environ.setdefault("PGADMIN_CONFIG_SESSION_DB_PATH", str(data_dir / "sessions"))
    os.environ.setdefault("PGADMIN_CONFIG_STORAGE_DIR", str(data_dir / "storage"))
    os.environ.setdefault("PGADMIN_CONFIG_SQLITE_PATH", str(data_dir / "pgadmin4.db"))
    os.environ.setdefault("PGADMIN_CONFIG_AZURE_CREDENTIAL_CACHE_DIR", str(data_dir / "azurecredentialcache"))
    os.environ.setdefault("PGADMIN_CONFIG_KERBEROS_CCACHE_DIR", str(data_dir / "kerberoscache"))


def main():
    _ensure_user_dirs()
    prog = os.path.basename(sys.argv[0]).lower()
    # If called as the CLI, delegate to setup:main; otherwise run web server runtime.
    if "pgadmin4-cli" in prog or "pgadmin4_cli" in prog:
        from pgadmin4.setup import main as _cli_main
        return _cli_main()
    else:
        from pgadmin4.pgAdmin4 import main as _web_main
        return _web_main()
