#!/bin/sh
# Starts the server on herdr-core and checks that it serves the client and gates its API with the token.
set -eu

# a short HOME: herdr-core and ovis put unix sockets under it (~104 bytes max on macOS)
home=$(mktemp -d /tmp/ovis.XXXXXX)
export HOME="$home" XDG_CONFIG_HOME="$home/c" XDG_STATE_HOME="$home/s" XDG_RUNTIME_DIR="$home/r"
mkdir -p "$XDG_RUNTIME_DIR"
port=17317
token=conda-forge-test-token-0123456789

cleanup() {
  kill "$pid" 2>/dev/null || true
  hc server stop >/dev/null 2>&1 || true
  rm -rf "$home"
}

PORT=$port OVIS_TOKEN=$token ovis >"$home/serve.log" 2>&1 &
pid=$!
trap cleanup EXIT

i=0
until curl -fsS -o /dev/null "http://127.0.0.1:$port/api/health"; do
  i=$((i + 1))
  if [ "$i" -gt 60 ] || ! kill -0 "$pid" 2>/dev/null; then
    cat "$home/serve.log"
    exit 1
  fi
  sleep 1
done
cat "$home/serve.log"

check() {
  if [ "$2" != "$3" ]; then
    echo "FAIL: $1: expected $3, got $2" >&2
    exit 1
  fi
  echo "ok: $1"
}

grep -q "Runtime: herdr-core" "$home/serve.log"
echo "ok: runs on herdr-core"
check "health reports herdr-core" "$(curl -fsS "http://127.0.0.1:$port/api/health" | grep -c "\"runtime\":\"herdr-core\"")" 1
curl -fsS "http://127.0.0.1:$port/" -o "$home/index.html"
check "serves the client" "$(grep -c 'id="root"' "$home/index.html")" 1
check "API without token" "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/api/access")" 401
check "API with token" "$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" "http://127.0.0.1:$port/api/access")" 200
