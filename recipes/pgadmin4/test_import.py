"""Import ``pgadmin4.pgAdmin4`` the way the ``pgadmin4`` console script does.

``pgAdmin4.py`` builds the Flask app at module scope, so importing it runs
``create_app()`` and ``run_before_app_start()``: the SQLite config database,
the session store and the storage directory are all created as a side effect.
In server mode -- the default, and what this package installs -- upstream puts
those under ``/var/lib/pgadmin`` and ``/var/log/pgadmin``, which a conda
environment neither owns nor can create as an unprivileged user.

Redirecting them is the whole job of ``pgadmin4.conda_entry``, so this test
drives that module rather than arranging its own override: point HOME and the
XDG variables at a scratch tree, call ``_ensure_user_dirs()`` exactly as the
console scripts do, import pgAdmin, and then check where pgAdmin actually
decided to put its files.

``PGADMIN_SETUP_EMAIL``/``PGADMIN_SETUP_PASSWORD`` are needed because the
first-run migration creates the initial admin account and otherwise prompts on
stdin, which is closed during a build.
"""

import os
import shutil
import tempfile

# Not TemporaryDirectory(): importing pgAdmin leaves the Flask app holding
# the SQLite config database open, and Windows refuses to unlink a file that
# is still open, so the context manager's cleanup raises WinError 32 after
# every assertion has already passed. POSIX allows unlinking an open file,
# which is why this only breaks on win-64. The directory lives under the OS
# temp area, so a best-effort removal is enough.
tmp_dir = tempfile.mkdtemp()
try:
    home = os.path.join(tmp_dir, "home")
    xdg_data = os.path.join(home, "data")
    xdg_state = os.path.join(home, "state")

    os.environ.update(
        HOME=home,
        XDG_DATA_HOME=xdg_data,
        XDG_STATE_HOME=xdg_state,
        XDG_CACHE_HOME=os.path.join(home, "cache"),
        PGADMIN_SETUP_EMAIL="conda-forge@example.com",
        PGADMIN_SETUP_PASSWORD="conda-forge-build-test",
    )
    # Anything inherited from the build environment would mask what the
    # wrapper does, which is precisely what is under test here.
    for stale in ("CONFIG_DISTRO_FILE_PATH", "PGADMIN_DATA_DIR",
                  "PGADMIN_STATE_DIR", "PGADMIN_CACHE_DIR"):
        os.environ.pop(stale, None)

    # Both console scripts resolve against conda_entry.
    import pgadmin4.conda_entry as conda_entry  # noqa: E402

    assert callable(conda_entry.main), "pgadmin4.conda_entry.main is not callable"
    assert callable(
        conda_entry.cli_main
    ), "pgadmin4.conda_entry.cli_main is not callable"

    # This is the first thing both entry points do, before importing pgAdmin.
    conda_entry._ensure_user_dirs()

    expected_data_dir = os.path.join(xdg_data, "pgadmin4")
    assert os.path.isdir(
        expected_data_dir
    ), "_ensure_user_dirs() did not create {}".format(expected_data_dir)

    distro_config = os.environ.get("CONFIG_DISTRO_FILE_PATH")
    assert distro_config and os.path.isfile(
        distro_config
    ), "_ensure_user_dirs() did not write a config_distro.py for pgAdmin"

    import pgadmin4.pgAdmin4 as pgadmin4_main  # noqa: E402

    assert callable(pgadmin4_main.main), "pgadmin4.pgAdmin4.main is not callable"
    assert pgadmin4_main.app is not None, "pgadmin4.pgAdmin4.app was not created"

    # The point of the wrapper: every path pgAdmin derives from DATA_DIR has to
    # land in the per-user tree, not in the unwritable system locations that
    # server mode defaults to.
    config = pgadmin4_main.config
    assert config.SERVER_MODE is True, "expected the default server mode"

    derived_paths = {
        "DATA_DIR": config.DATA_DIR,
        "SQLITE_PATH": config.SQLITE_PATH,
        "LOG_FILE": config.LOG_FILE,
        "SESSION_DB_PATH": config.SESSION_DB_PATH,
        "STORAGE_DIR": config.STORAGE_DIR,
        "AZURE_CREDENTIAL_CACHE_DIR": config.AZURE_CREDENTIAL_CACHE_DIR,
        "KERBEROS_CCACHE_DIR": config.KERBEROS_CCACHE_DIR,
    }
    for name, path in derived_paths.items():
        assert os.path.realpath(path).startswith(
            os.path.realpath(expected_data_dir)
        ), "config.{} is {!r}, expected it under {!r}".format(
            name, path, expected_data_dir
        )

    # The config database is created during the import, so it proves the
    # redirected path was not merely computed but actually written to.
    assert os.path.isfile(
        config.SQLITE_PATH
    ), "config database was not created at {}".format(config.SQLITE_PATH)

    for name, path in sorted(derived_paths.items()):
        print("{}: {}".format(name, path))

finally:
    shutil.rmtree(tmp_dir, ignore_errors=True)

print("pgadmin4.conda_entry redirected pgAdmin away from the system data dirs")
