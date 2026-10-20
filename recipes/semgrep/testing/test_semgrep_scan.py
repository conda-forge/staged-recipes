"""Smoke test for the semgrep CLI: print the version, then scan one file with one rule.

Python rather than a shell script so the same test runs on unix and non-unix (cmd).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

RULE = """rules:
  - id: no-print
    pattern: print(...)
    message: no print
    languages: [python]
    severity: WARNING
"""


# Runs the pysemgrep console-script target in-process, bypassing the .EXE launcher.
# Writes to a file so the result survives unusable std handles.
PROBE = """import sys, traceback
log = open(sys.argv[1], "w")
print("stdout=%r stderr=%r" % (sys.stdout, sys.stderr), file=log)
sys.argv = ["pysemgrep", "--version"]
try:
    from semgrep.console_scripts.pysemgrep import main
    main()
    print("main() returned", file=log)
except SystemExit as e:
    print("SystemExit %r" % (e.code,), file=log)
    traceback.print_exc(file=log)
except BaseException:
    traceback.print_exc(file=log)
log.close()
"""


def show(label, args, **kw):
    """Run args, print exit code and output, never raise."""
    try:
        p = subprocess.run(args, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=120, **kw)
    except Exception as e:  # noqa: BLE001
        print("[%s] %r raised %r" % (label, args, e))
        return None
    print("[%s] %r -> %d" % (label, args, p.returncode))
    if p.stdout.strip():
        print("  stdout: %s" % p.stdout.strip()[-2000:])
    if p.stderr.strip():
        print("  stderr: %s" % p.stderr.strip()[-2000:])
    return p


def diagnose(semgrep, env, work):
    """Check each layer: pysemgrep, the semgrep.cli import, semgrep-core, and semgrep-core run as osemgrep."""
    core = shutil.which("semgrep-core")
    print("semgrep: %s" % semgrep)
    print("semgrep-core: %s" % core)
    pysemgrep = shutil.which("pysemgrep")
    print("pysemgrep: %s" % pysemgrep)
    if pysemgrep is not None:
        show("pysemgrep", [pysemgrep, "--version"], env=env)
        # Without the SEMGREP_SETTINGS_FILE/SEMGREP_VERSION_CACHE_PATH overrides.
        show("pysemgrep-plain-env", [pysemgrep, "--version"])
    show("legacy", [semgrep, "--legacy", "--version"], env=env)
    show("import-cli", [sys.executable, "-X", "faulthandler", "-c",
                        "import semgrep.cli"], env=env)
    probe = os.path.join(work, "probe.py")
    with open(probe, "w") as f:
        f.write(PROBE)
    probe_log = os.path.join(work, "probe.log")
    show("in-process", [sys.executable, "-X", "faulthandler", probe, probe_log], env=env)
    if os.path.exists(probe_log):
        with open(probe_log, errors="replace") as f:
            print("  probe.log:\n%s" % f.read()[-4000:])
    # Console-script launcher: list what sits next to the .EXE and run its -script.py.
    scripts = os.path.dirname(semgrep)
    print("scripts: %r" % sorted(n for n in os.listdir(scripts) if "semgrep" in n.lower()))
    for name in ("pysemgrep-script.py", "semgrep-script.py"):
        path = os.path.join(scripts, name)
        if os.path.exists(path):
            show(name, [sys.executable, path, "--version"], env=env)
    if core is None:
        return
    show("core", [core, "-version"], env=env)
    show("osemgrep-argv0", ["osemgrep", "--version"], executable=core, env=env)
    show("osemgrep-argv0-debug", ["osemgrep", "--version", "--debug"],
         executable=core, env=env)
    # Real file named osemgrep, in case argv0 is not seen on non-unix.
    alias = os.path.join(work, "osemgrep" + os.path.splitext(core)[1])
    shutil.copy(core, alias)
    show("osemgrep-copy", [alias, "--version"], env=env)
    show("osemgrep-copy-debug", [alias, "--version", "--debug"], env=env)


def main():
    # non-unix console is cp1252; semgrep's stderr has characters it cannot encode
    sys.stdout.reconfigure(errors="replace")
    semgrep = shutil.which("semgrep")
    if semgrep is None:
        sys.exit("semgrep not found on PATH")
    work = tempfile.mkdtemp()
    with open(os.path.join(work, "rule.yaml"), "w") as f:
        f.write(RULE)
    with open(os.path.join(work, "test.py"), "w") as f:
        f.write('print("hi")\n')
    env = dict(
        os.environ,
        SEMGREP_ENABLE_VERSION_CHECK="0",
        SEMGREP_SEND_METRICS="off",
        SEMGREP_SETTINGS_FILE=os.path.join(work, "s.yaml"),
        SEMGREP_VERSION_CACHE_PATH=os.path.join(work, "vc"),
    )
    p = show("semgrep", [semgrep, "--version"], env=env)
    if p is None or p.returncode != 0:
        diagnose(semgrep, env, work)
        show("semgrep-debug", [semgrep, "--version", "--debug"], env=env)
        sys.exit("semgrep --version failed")
    p = show("scan", [semgrep, "scan", "--metrics=off", "--disable-version-check",
                      "--config", "rule.yaml", "test.py", "--json"],
             env=env, cwd=work)
    if p is None or p.returncode != 0:
        diagnose(semgrep, env, work)
        sys.exit("semgrep scan failed")
    ids = [r["check_id"] for r in json.loads(p.stdout)["results"]]
    if not any(i.endswith("no-print") for i in ids):
        sys.exit("no-print finding not reported: %r" % ids)
    print("ok: %r" % ids)


if __name__ == "__main__":
    main()
