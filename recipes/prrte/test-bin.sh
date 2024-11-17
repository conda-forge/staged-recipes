set -ex

prte_info

prun -n 2 sh -c 'echo hi'
