# Check for recent enough version of bash.
# This is the same check used in the integration script
if [ "${BASH_VERSINFO[0]}" -gt 4 ] || \
    [ "${BASH_VERSINFO[0]}" -eq 4 -a "${BASH_VERSINFO[1]}" -ge 1 ]; then

    # Ensure the library loads without error at least
    bash -e mamba
fi
