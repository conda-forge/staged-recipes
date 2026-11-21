#!/bin/sh
# Launcher for the Ovis server as packaged by conda-forge.
#
# Runs the server on herdr-core from this environment, with telemetry and the ovis.sh account service
# off unless set otherwise, and refuses to listen beyond loopback without a token.
set -eu

prefix=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

usage() {
  cat <<EOF
usage: ovis [serve]

Starts the Ovis web server (default http://127.0.0.1:7317) for herdr-core.

Environment (defaults set by this launcher in parentheses):
  HOST, PORT                  address to listen on (127.0.0.1, 7317)
  OVIS_TOKEN                  access token; required when HOST is not a loopback address
  OVIS_RUNTIME                herdr-core or herdr (herdr-core)
  OVIS_HC_BIN                 herdr-core's hc binary (\$CONDA_PREFIX/bin/hc)
  OVIS_PTY_SIDECAR_BIN        Rust PTY host (\$CONDA_PREFIX/libexec/ovis/ovis-pty-sidecar)
  OVIS_TELEMETRY              anonymous usage counts, 1 to enable (0)
  OVIS_ACCOUNT_SERVICE_URL    Ovis account service, a URL to enable (off)
  OVIS_STATE_DIR              state directory (~/.config/ovis)

See https://github.com/devswha/ovis/blob/main/docs/guide.md for all settings.
EOF
}

case "${1:-serve}" in
  serve) ;;
  -h | --help | help) usage; exit 0 ;;
  -V | --version | version) echo "ovis @VERSION@"; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

export OVIS_RUNTIME="${OVIS_RUNTIME:-herdr-core}"
if [ -z "${OVIS_HC_BIN:-}" ] && [ -x "$prefix/bin/hc" ]; then
  export OVIS_HC_BIN="$prefix/bin/hc"
fi
export OVIS_PTY_SIDECAR_BIN="${OVIS_PTY_SIDECAR_BIN:-$prefix/libexec/ovis/ovis-pty-sidecar}"
export OVIS_TELEMETRY="${OVIS_TELEMETRY:-0}"
export OVIS_ACCOUNT_SERVICE_URL="${OVIS_ACCOUNT_SERVICE_URL:-off}"

host="${HOST:-127.0.0.1}"
case "$host" in
  127.0.0.1 | localhost | ::1) ;;
  *)
    if [ -z "${OVIS_TOKEN:-}" ]; then
      echo "ovis: HOST=$host lets anyone who can reach it type into your terminals; set OVIS_TOKEN to a long random value" >&2
      exit 1
    fi
    ;;
esac

exec "$prefix/bin/bun" "$prefix/share/ovis/server/index.ts"
