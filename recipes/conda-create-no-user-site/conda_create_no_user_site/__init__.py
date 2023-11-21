from pathlib import Path

from conda import plugins
from conda.base.context import context
from conda.core.prefix_data import PrefixData


def action(argv: list) -> None:
    target_prefix = context.target_prefix
    python = PrefixData(target_prefix).get("python", None)
    if python:
        pyvenv_cfg = Path(target_prefix, "pyvenv.cfg")
        with pyvenv_cfg.open("x", encoding="utf-8") as f:
            f.write("include-system-site-packages = false\n")


@plugins.hookimpl
def conda_post_commands():
    yield plugins.CondaPostCommand(
        name="no-user-site",
        action=action,
        run_for={"create"},
    )
