"""``mybmad`` launcher: run the MyBMAD Dashboard web app with a self-managed
local PostgreSQL database.

The conda package ships a prebuilt Next.js ``standalone`` server bundle under
``mybmad_dashboard/app``. This module:

  * resolves a per-user data directory (``$MYBMAD_HOME``),
  * provisions/starts a local PostgreSQL cluster there (``initdb``/``pg_ctl``),
  * generates and persists application secrets on first run,
  * applies Prisma migrations (offline, using the bundled Prisma CLI),
  * runs the web server (``node server.js``) in the foreground.

It uses ONLY the Python standard library, plus the ``node`` and PostgreSQL
binaries (``initdb``, ``pg_ctl``, ``createdb``, ``psql``) provided as conda
runtime dependencies. The upstream source is not modified; this is pure glue.
"""

from __future__ import annotations

import argparse
import atexit
import json
import os
import secrets
import shutil
import socket
import subprocess
import sys
import time
from importlib.resources import files
from pathlib import Path

from . import DB_NAME, DB_USER, DEFAULT_DB_PORT, DEFAULT_PORT

# ---------------------------------------------------------------------------
# Path / config resolution
# ---------------------------------------------------------------------------


def _app_dir() -> Path:
    """Return the bundled Next.js standalone runner directory."""
    app = Path(str(files(__package__) / "app"))
    if not app.is_dir():
        raise FileNotFoundError(
            f"Bundled app not found at {app}. The conda package is malformed; "
            "please reinstall."
        )
    return app


def _server_js() -> Path:
    server = _app_dir() / "server.js"
    if not server.is_file():
        raise FileNotFoundError(
            f"server.js not found at {server}. The standalone bundle is "
            "incomplete; please reinstall."
        )
    return server


def _query_engine() -> Path | None:
    """Locate the bundled Prisma native query engine library.

    The filename is platform-specific (libquery_engine-<target>.{dylib.,so.,}node);
    exactly one is bundled — the build platform's — so glob and return it.
    """
    gen = _app_dir() / "src" / "generated" / "prisma"
    if not gen.is_dir():
        return None
    libs = sorted(gen.glob("libquery_engine-*.node"))
    return libs[0] if libs else None


def _data_dir() -> Path:
    """Per-user data directory for the Postgres cluster, logs, and secrets."""
    override = os.environ.get("MYBMAD_HOME")
    if override:
        base = Path(override).expanduser()
    elif sys.platform.startswith("win"):
        base = Path(os.environ.get("LOCALAPPDATA", Path.home() / "AppData" / "Local")) / "mybmad"
    else:
        xdg = os.environ.get("XDG_DATA_HOME")
        base = (Path(xdg) if xdg else Path.home() / ".local" / "share") / "mybmad"
    base.mkdir(parents=True, exist_ok=True)
    return base


def _pgdata(data_dir: Path) -> Path:
    return data_dir / "pgdata"


def _pg_log(data_dir: Path) -> Path:
    return data_dir / "postgres.log"


def _config_path(data_dir: Path) -> Path:
    return data_dir / "config.json"


def _load_or_init_config(data_dir: Path) -> dict:
    """Load persisted secrets, generating them on first run."""
    path = _config_path(data_dir)
    if path.is_file():
        cfg = json.loads(path.read_text(encoding="utf-8"))
    else:
        cfg = {}
    changed = False
    if not cfg.get("better_auth_secret"):
        cfg["better_auth_secret"] = secrets.token_urlsafe(48)
        changed = True
    if not cfg.get("revalidate_secret"):
        cfg["revalidate_secret"] = secrets.token_hex(32)
        changed = True
    if changed:
        path.write_text(json.dumps(cfg, indent=2) + "\n", encoding="utf-8")
        try:
            path.chmod(0o600)
        except OSError:
            pass  # best effort on platforms without POSIX perms
    return cfg


def _port(env_var: str, default: int) -> int:
    raw = os.environ.get(env_var)
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        raise SystemExit(f"{env_var} must be an integer, got {raw!r}")


def _bool_env(env_var: str, default: bool) -> bool:
    raw = os.environ.get(env_var)
    if raw is None:
        return default
    return raw.strip().lower() in ("1", "true", "yes", "on")


def _which(name: str) -> str:
    path = shutil.which(name)
    if not path:
        raise SystemExit(
            f"Required executable {name!r} not found on PATH. Ensure the conda "
            "environment with `nodejs` and `postgresql` is active."
        )
    return path


def _database_url(db_port: int) -> str:
    # `initdb` below uses trust auth on localhost, so no password is needed.
    return f"postgresql://{DB_USER}@127.0.0.1:{db_port}/{DB_NAME}"


# ---------------------------------------------------------------------------
# PostgreSQL lifecycle
# ---------------------------------------------------------------------------


def _run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    print("$ " + " ".join(cmd), flush=True)
    return subprocess.run(cmd, **kwargs)


def _pg_is_running(data_dir: Path) -> bool:
    pg_ctl = shutil.which("pg_ctl")
    if not pg_ctl:
        return False
    res = subprocess.run(
        [pg_ctl, "-D", str(_pgdata(data_dir)), "status"],
        capture_output=True,
    )
    return res.returncode == 0


def _wait_for_pg(db_port: int, timeout: float = 30.0) -> None:
    """Block until Postgres accepts TCP connections on db_port."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(1.0)
            if s.connect_ex(("127.0.0.1", db_port)) == 0:
                return
        time.sleep(0.5)
    raise SystemExit(
        f"PostgreSQL did not become ready on port {db_port} within {timeout:.0f}s. "
        f"Check the log at {_pg_log(_data_dir())}."
    )


def _ensure_pg_initialized(data_dir: Path) -> None:
    pgdata = _pgdata(data_dir)
    if (pgdata / "PG_VERSION").is_file():
        return
    initdb = _which("initdb")
    print(f">> initializing PostgreSQL cluster at {pgdata}", flush=True)
    pgdata.mkdir(parents=True, exist_ok=True)
    # `trust` auth: only this local user can reach 127.0.0.1; no password to
    # manage. The cluster lives in the user's private data dir.
    res = _run(
        [initdb, "-D", str(pgdata), "-U", DB_USER, "--auth=trust", "--encoding=UTF8"],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit("initdb failed.")


def _start_pg(data_dir: Path, db_port: int) -> None:
    if _pg_is_running(data_dir):
        print(">> PostgreSQL already running", flush=True)
        return
    pg_ctl = _which("pg_ctl")
    pgdata = _pgdata(data_dir)
    log = _pg_log(data_dir)
    print(f">> starting PostgreSQL on port {db_port}", flush=True)
    # -k '' disables the unix socket dir default oddities; bind localhost only.
    res = _run(
        [
            pg_ctl,
            "-D", str(pgdata),
            "-l", str(log),
            "-o", f"-p {db_port} -c listen_addresses=127.0.0.1",
            "-w",  # wait for startup
            "start",
        ],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit(f"pg_ctl start failed. See log: {log}")
    _wait_for_pg(db_port)


def _stop_pg(data_dir: Path) -> None:
    if not _pg_is_running(data_dir):
        return
    pg_ctl = _which("pg_ctl")
    print(">> stopping PostgreSQL", flush=True)
    _run(
        [pg_ctl, "-D", str(_pgdata(data_dir)), "-m", "fast", "-w", "stop"],
        capture_output=True,
        text=True,
    )


def _ensure_database(db_port: int) -> None:
    """Create the application database if it does not exist."""
    psql = _which("psql")
    check = subprocess.run(
        [
            psql, "-h", "127.0.0.1", "-p", str(db_port), "-U", DB_USER,
            "-d", "postgres", "-tAc",
            f"SELECT 1 FROM pg_database WHERE datname='{DB_NAME}'",
        ],
        capture_output=True,
        text=True,
    )
    if check.stdout.strip() == "1":
        return
    createdb = _which("createdb")
    print(f">> creating database {DB_NAME}", flush=True)
    res = _run(
        [createdb, "-h", "127.0.0.1", "-p", str(db_port), "-U", DB_USER, DB_NAME],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit("createdb failed.")


# ---------------------------------------------------------------------------
# Migrations (psql, no Prisma CLI/engine at runtime)
# ---------------------------------------------------------------------------
#
# Upstream's prisma/migrations/<name>/migration.sql files are plain PostgreSQL
# DDL. We apply them with psql, tracking applied migrations in a small table so
# re-runs are idempotent. This avoids shipping the Prisma CLI + native engines
# (which live behind pnpm symlinks and would otherwise need a network download).

_MIGRATIONS_TABLE = "_mybmad_migrations"


def _migrations_dir() -> Path:
    d = _app_dir() / "prisma" / "migrations"
    if not d.is_dir():
        raise FileNotFoundError(
            f"Migrations not found at {d}. The package is malformed; reinstall."
        )
    return d


def _psql_base(db_port: int) -> list[str]:
    return [
        _which("psql"),
        "-h", "127.0.0.1",
        "-p", str(db_port),
        "-U", DB_USER,
        "-d", DB_NAME,
        "-v", "ON_ERROR_STOP=1",
    ]


def _apply_migrations(db_port: int) -> None:
    base = _psql_base(db_port)

    # Ensure the tracking table exists.
    res = subprocess.run(
        base + ["-c", (
            f"CREATE TABLE IF NOT EXISTS {_MIGRATIONS_TABLE} "
            "(name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())"
        )],
        capture_output=True, text=True,
    )
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit("Failed to create migration tracking table.")

    # Which migrations are already applied?
    res = subprocess.run(
        base + ["-tAc", f"SELECT name FROM {_MIGRATIONS_TABLE}"],
        capture_output=True, text=True,
    )
    applied = {line.strip() for line in res.stdout.splitlines() if line.strip()}

    mig_dir = _migrations_dir()
    names = sorted(p.name for p in mig_dir.iterdir() if p.is_dir())
    pending = [n for n in names if n not in applied]
    if not pending:
        print(">> database schema up to date", flush=True)
        return

    for name in pending:
        sql_file = mig_dir / name / "migration.sql"
        if not sql_file.is_file():
            continue
        print(f">> applying migration {name}", flush=True)
        # Run the migration and record it atomically in one transaction.
        script = (
            "BEGIN;\n"
            f"\\i {sql_file}\n"
            f"INSERT INTO {_MIGRATIONS_TABLE}(name) VALUES ('{name}');\n"
            "COMMIT;\n"
        )
        res = subprocess.run(base, input=script, text=True)
        if res.returncode != 0:
            raise SystemExit(f"Migration {name} failed.")


# ---------------------------------------------------------------------------
# Web server
# ---------------------------------------------------------------------------


def _server_env(data_dir: Path, web_port: int, db_port: int) -> dict:
    cfg = _load_or_init_config(data_dir)
    env = os.environ.copy()
    env.update(
        {
            "NODE_ENV": "production",
            "NEXT_TELEMETRY_DISABLED": "1",
            "PORT": str(web_port),
            "HOSTNAME": os.environ.get("MYBMAD_HOSTNAME", "127.0.0.1"),
            "DATABASE_URL": _database_url(db_port),
            "BETTER_AUTH_SECRET": cfg["better_auth_secret"],
            "BETTER_AUTH_URL": os.environ.get(
                "MYBMAD_BETTER_AUTH_URL", f"http://localhost:{web_port}"
            ),
            "REVALIDATE_SECRET": cfg["revalidate_secret"],
            # Local self-host: enable local-folder import by default (the
            # primary "develop projects on this machine" use case).
            "ENABLE_LOCAL_FS": "true" if _bool_env("MYBMAD_ENABLE_LOCAL_FS", True) else "false",
            "ALLOW_REGISTRATION": "true" if _bool_env("MYBMAD_ALLOW_REGISTRATION", True) else "false",
        }
    )
    # Point Prisma directly at the bundled native query engine. Flattening the
    # standalone bundle (removing the upstream `web/` nesting level) breaks
    # Prisma's relative engine auto-discovery, so it would otherwise search the
    # wrong paths ("Query Engine for runtime ... could not be located"). This
    # override is authoritative and platform-agnostic.
    engine = _query_engine()
    if engine:
        env["PRISMA_QUERY_ENGINE_LIBRARY"] = str(engine)

    # Pass through optional GitHub OAuth / PAT if the user set them.
    for key in ("GITHUB_CLIENT_ID", "GITHUB_CLIENT_SECRET", "GITHUB_PAT"):
        if os.environ.get(key):
            env[key] = os.environ[key]
    return env


def _start_server(data_dir: Path, web_port: int, db_port: int) -> int:
    node = _which("node")
    app = _app_dir()
    env = _server_env(data_dir, web_port, db_port)
    print(
        f">> starting MyBMAD Dashboard at http://localhost:{web_port}\n"
        f"   (data dir: {data_dir})\n"
        f"   Press Ctrl+C to stop.",
        flush=True,
    )
    proc = subprocess.Popen([node, str(_server_js())], cwd=str(app), env=env)
    try:
        return proc.wait()
    except KeyboardInterrupt:
        proc.terminate()
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
        return 0


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------


def cmd_up(args: argparse.Namespace) -> int:
    data_dir = _data_dir()
    web_port = _port("MYBMAD_PORT", args.port or DEFAULT_PORT)
    db_port = _port("MYBMAD_DB_PORT", args.db_port or DEFAULT_DB_PORT)

    _ensure_pg_initialized(data_dir)
    _start_pg(data_dir, db_port)
    if not args.keep_db_running:
        atexit.register(_stop_pg, data_dir)
    _ensure_database(db_port)
    _apply_migrations(db_port)
    return _start_server(data_dir, web_port, db_port)


def cmd_stop(_args: argparse.Namespace) -> int:
    _stop_pg(_data_dir())
    return 0


def cmd_migrate(args: argparse.Namespace) -> int:
    data_dir = _data_dir()
    db_port = _port("MYBMAD_DB_PORT", args.db_port or DEFAULT_DB_PORT)
    _ensure_pg_initialized(data_dir)
    _start_pg(data_dir, db_port)
    _ensure_database(db_port)
    _apply_migrations(db_port)
    return 0


def cmd_promote_admin(args: argparse.Namespace) -> int:
    """Set a registered user's role to admin via a plain SQL update.

    `role` is a plain column (no password hashing involved), so a direct SQL
    UPDATE is safe and avoids shipping the upstream tsx create-admin script.
    Register the account first via the web UI, then run this.
    """
    data_dir = _data_dir()
    db_port = _port("MYBMAD_DB_PORT", args.db_port or DEFAULT_DB_PORT)
    _start_pg(data_dir, db_port)
    psql = _which("psql")
    email = args.email.replace("'", "''")  # minimal SQL-literal escaping
    res = _run(
        [
            psql, "-h", "127.0.0.1", "-p", str(db_port), "-U", DB_USER,
            "-d", DB_NAME, "-tAc",
            f"UPDATE users SET role='admin' WHERE email='{email}' RETURNING email",
        ],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        return 1
    if res.stdout.strip():
        print(f">> {res.stdout.strip()} is now an admin.", flush=True)
        return 0
    print(
        f">> No user with email {args.email!r} found. Register at the web UI "
        "first, then re-run.",
        file=sys.stderr,
    )
    return 1


def cmd_info(args: argparse.Namespace) -> int:
    data_dir = _data_dir()
    web_port = _port("MYBMAD_PORT", DEFAULT_PORT)
    db_port = _port("MYBMAD_DB_PORT", DEFAULT_DB_PORT)

    if args.print_app_dir:
        print(_app_dir())
        return 0
    if args.print_server_js:
        print(_server_js())
        return 0

    print(f"app dir:       {_app_dir()}")
    print(f"server.js:     {_server_js()}")
    print(f"data dir:      {data_dir}")
    print(f"pg data:       {_pgdata(data_dir)}")
    print(f"pg log:        {_pg_log(data_dir)}")
    print(f"web port:      {web_port}")
    print(f"db port:       {db_port}")
    print(f"database url:  {_database_url(db_port)}")
    print(f"pg running:    {_pg_is_running(data_dir)}")
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="mybmad",
        description=(
            "Run the MyBMAD Dashboard web app with a self-managed local "
            "PostgreSQL database."
        ),
    )
    sub = parser.add_subparsers(dest="command")

    p_up = sub.add_parser("up", help="Start the database and web server (default).")
    p_up.add_argument("--port", type=int, help=f"Web server port (default {DEFAULT_PORT}).")
    p_up.add_argument("--db-port", type=int, help=f"Local Postgres port (default {DEFAULT_DB_PORT}).")
    p_up.add_argument(
        "--keep-db-running",
        action="store_true",
        help="Leave PostgreSQL running after the web server exits.",
    )
    p_up.set_defaults(func=cmd_up)

    p_stop = sub.add_parser("stop", help="Stop the managed PostgreSQL cluster.")
    p_stop.set_defaults(func=cmd_stop)

    p_mig = sub.add_parser("migrate", help="Apply database migrations and exit.")
    p_mig.add_argument("--db-port", type=int)
    p_mig.set_defaults(func=cmd_migrate)

    p_adm = sub.add_parser("promote-admin", help="Grant admin role to a registered user.")
    p_adm.add_argument("--email", required=True, help="Email of the user to promote.")
    p_adm.add_argument("--db-port", type=int)
    p_adm.set_defaults(func=cmd_promote_admin)

    p_info = sub.add_parser("info", help="Print resolved paths and settings.")
    p_info.add_argument("--print-app-dir", action="store_true", help="Print the bundled app dir and exit.")
    p_info.add_argument("--print-server-js", action="store_true", help="Print server.js path and exit.")
    p_info.set_defaults(func=cmd_info)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    # Default subcommand: `up`.
    if not getattr(args, "command", None):
        args = parser.parse_args(["up", *(argv or [])])
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
