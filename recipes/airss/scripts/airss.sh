#!/usr/bin/env bash
airss_bin="@PREFIX@/libexec/airss"
cmd="${1-__missing__}"

export PATH="$airss_bin:$PATH"
if [ -x "$airss_bin/$cmd" ]; then
  shift
  exec "$airss_bin/$cmd" "$@"
elif [ "$cmd" == "version" ]; then
  shift
  exec "$airss_bin/airss_version" "$@"
else
  exec "$airss_bin/airss.pl" "$@"
fi
