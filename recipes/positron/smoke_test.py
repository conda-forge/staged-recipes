"""Launch the Positron GUI and check that a workbench window comes up.

Starts the real Electron app (not the ELECTRON_RUN_AS_NODE CLI path used by
`positron --version`) with a throwaway profile, then waits for the first
window's renderer log, which Positron only writes once a BrowserWindow has been
created and its renderer process has started. The extension host log is
reported as extra evidence that the workbench finished loading.
"""
import glob
import os
import plistlib
import shutil
import signal
import subprocess
import sys
import tempfile
import time

TIMEOUT = 180


def app_executable(prefix):
    if sys.platform == "darwin":
        app = os.path.join(prefix, "lib", "Positron.app")
        with open(os.path.join(app, "Contents", "Info.plist"), "rb") as fh:
            exe = plistlib.load(fh)["CFBundleExecutable"]
        return os.path.join(app, "Contents", "MacOS", exe)
    if sys.platform == "win32":
        return os.path.join(prefix, "Library", "lib", "positron", "Positron.exe")
    return os.path.join(prefix, "lib", "positron", "positron")


def stop(proc):
    if proc.poll() is not None:
        return
    if sys.platform == "win32":
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(proc.pid)], capture_output=True)
    else:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    proc.wait(timeout=30)


def main():
    prefix = os.environ.get("PREFIX") or sys.prefix
    exe = app_executable(prefix)
    tmp = tempfile.mkdtemp(prefix="positron-smoke-")
    user_data = os.path.join(tmp, "user-data")
    # Positron writes logs under $XDG_STATE_HOME / ~/.local/state by default; pin them here
    logs = os.path.join(tmp, "logs")
    workspace = os.path.join(tmp, "workspace")
    os.makedirs(workspace)
    os.makedirs(os.path.join(user_data, "User"))
    with open(os.path.join(user_data, "User", "settings.json"), "w") as fh:
        fh.write('{"update.mode": "none", "telemetry.telemetryLevel": "off"}')
    args = [
        exe,
        "--user-data-dir", user_data,
        "--logsPath", logs,
        "--extensions-dir", os.path.join(tmp, "extensions"),
        "--disable-gpu",
        "--no-sandbox",
        "--skip-welcome",
        "--skip-release-notes",
        "--disable-workspace-trust",
        "--new-window",
        workspace,
    ]
    if sys.platform.startswith("linux"):
        # no display on CI: use Chromium's headless Ozone platform
        args.insert(1, "--ozone-platform=headless")
    env = dict(os.environ)
    env.pop("ELECTRON_RUN_AS_NODE", None)
    print("smoke test:", " ".join(args), flush=True)
    out = open(os.path.join(tmp, "stdout.log"), "w")
    kw = {"start_new_session": True} if sys.platform != "win32" else {}
    proc = subprocess.Popen(args, env=env, stdout=out, stderr=subprocess.STDOUT, **kw)

    renderer = exthost = None
    deadline = time.time() + TIMEOUT
    try:
        while time.time() < deadline:
            renderer = renderer or next(iter(glob.glob(os.path.join(logs, "**", "window*", "renderer.log"), recursive=True)), None)
            exthost = exthost or next(iter(glob.glob(os.path.join(logs, "**", "exthost*.log"), recursive=True)), None)
            if renderer and exthost:
                break
            if proc.poll() is not None:
                break
            time.sleep(2)
        if renderer and not exthost and proc.poll() is None:
            # give the workbench a little longer to start the extension host
            time.sleep(20)
            exthost = next(iter(glob.glob(os.path.join(logs, "**", "exthost*.log"), recursive=True)), None)
        exited = proc.poll()
    finally:
        stop(proc)
        out.close()

    print(f"renderer log: {renderer}")
    print(f"extension host log: {exthost}")
    if not renderer:
        print(f"FAILED: no workbench window within {TIMEOUT}s (process exit code: {exited})")
        print("log files:", sorted(os.path.relpath(f, logs) for f in glob.glob(os.path.join(logs, "**", "*"), recursive=True)))
        for log in [os.path.join(tmp, "stdout.log")] + glob.glob(os.path.join(logs, "**", "main.log"), recursive=True):
            print(f"--- {log} (tail) ---")
            with open(log, errors="replace") as fh:
                print("".join(fh.readlines()[-40:]))
        sys.exit(1)
    print("OK: Positron opened a workbench window" + (" and started the extension host" if exthost else ""))
    shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
