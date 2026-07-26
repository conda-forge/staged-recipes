"""MyBMAD Dashboard — conda packaging wrapper.

The conda package ships a prebuilt Next.js `standalone` server bundle under
``mybmad_dashboard/app`` and exposes a ``mybmad`` launcher (see
:mod:`mybmad_dashboard.launcher`) that provisions a local PostgreSQL cluster
and runs the web app.
"""

from __future__ import annotations

__version__ = "0.1.0.dev0"

# Default web server port (upstream `next dev`/`next start` use 3002).
DEFAULT_PORT = 3002

# Default local PostgreSQL port for the launcher-managed cluster. Chosen to be
# unlikely to collide with a system Postgres on 5432/5433.
DEFAULT_DB_PORT = 54329

# Database/user names for the launcher-managed cluster.
DB_NAME = "bmad_dashboard"
DB_USER = "bmad"
