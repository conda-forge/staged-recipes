set -ex

prte_info

prun --do-not-connect --allow-run-as-root -n 2 sh -c 'echo hi'
