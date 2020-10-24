#!/bin/bash
set -euo pipefail

echo -e '1\t2\t3' > test.bed
bgzip test.bed
tabix test.bed.gz
htsfile test.bed.gz > /dev/null
