"""Print all jupyter-server-proxy endpoints."""

from importlib.metadata import entry_points
import sys

if sys.version_info >= (3, 10):
    endpoints = entry_points(group="jupyter_serverproxy_servers")
else:
    endpoints = entry_points().get("jupyter_serverproxy_servers", [])

for ep in endpoints:
    print(ep.value.split(":")[0])
