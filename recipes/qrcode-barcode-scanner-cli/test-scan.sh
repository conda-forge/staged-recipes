#!/bin/bash
# The installed qrscan reads the QR code and the Code 128 of the mixed fixture in every profile.
set -euo pipefail
image=$1
for profile in fast frame full; do
  qrscan --profile "$profile" --budget-ms 0 "$image" >"scan-$profile.json"
  grep -qF '"text": "https://qrc-ai.com/76xMa"' "scan-$profile.json"
  grep -qF '"text": "STOCK-4827"' "scan-$profile.json"
  echo "ok $profile"
done
