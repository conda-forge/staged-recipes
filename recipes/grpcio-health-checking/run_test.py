""" grpc_version.py is generated during the build, capturing the version of grpcio
    used to generate code from the protocol buffer definitions.

    Historically, the grpc_version.VERSION has always matched PKG_VERSION.
"""
import os
import grpc_version
import sys

PKG_VERSION = os.environ["PKG_VERSION"]
GRPC_VERSION = grpc_version.VERSION

print("""
Checking grpc versions:
  - recipe:           {pkg}
  - grpc_version.py:  {grpc}
""".format(pkg=PKG_VERSION, grpc=GRPC_VERSION))

if PKG_VERSION != GRPC_VERSION:
    print("... grpc_version.py does not match package version")
    sys.exit(1)

print("... versions match")
