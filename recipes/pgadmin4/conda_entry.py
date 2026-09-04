"""Console-script wrapper for the conda packaging of pgAdmin 4.

Upstream's entry points assume a system-wide install: in server mode
``config.DATA_DIR`` is ``/var/lib/pgadmin`` and ``config.LOG_FILE`` is
``/var/log/pgadmin``, neither of which a conda environment owns or can create
as an unprivileged user. Both console scripts therefore route through this
module, which puts the data directory in a per-user XDG location and hands
pgAdmin that path through ``config_distro.py`` -- the override file packagers
are meant to supply -- before delegating to the upstream entry point.
"""

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
        except OSError:
            # POSIX permissions are advisory on Windows and unavailable on
            # some network filesystems; the directory is still usable.
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
    """Entry point for the ``pgadmin4`` console script -- the web runtime."""
    _ensure_user_dirs()
    # Kept for anyone invoking this module directly: if argv[0] names the CLI
    # script, route there rather than starting a web server.
    prog = os.path.basename(sys.argv[0]).lower()
    if "pgadmin4-cli" in prog or "pgadmin4_cli" in prog:
        from pgadmin4.setup import main as _cli_main
        return _cli_main()

    from pgadmin4.pgAdmin4 import main as _web_main
    return _web_main()


def cli_main():
    """Entry point for the ``pgadmin4-cli`` console script."""
    _ensure_user_dirs()
    from pgadmin4.setup import main as _cli_main
    return _cli_main()
