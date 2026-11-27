"""A design built through the client, against the ``solidcraft-cli`` this package depends on.

The test runs with ``SOLIDCRAFT_NO_DOWNLOAD=1``, so it only passes when the client finds the CLI
from the conda environment on ``PATH`` and the two agree on the protocol.
"""

import solidcraft as sc

with sc.session() as d:
    d.cmd.solid.box(length="10 mm", width="10 mm", height="10 mm", body_name="Box")
    report = d.changes()

assert "Box" in report, report
print(report)
