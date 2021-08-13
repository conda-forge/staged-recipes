# Use the "bash" installed as a dependency

bash -e <<EOF
echo "Sourcing the bash-completion library"
. "$PREFIX"/share/bash-completion/bash_completion

# Ensure the library loads without error at least
echo "Ensure the completion script can be loaded"
. "$PREFIX"/share/bash-completion/completions/mamba
EOF
