# unsetup any products to keep env clean
# topological sort makes it faster since unsetup works on deps too
pkg=`eups list -s --topological -D --raw 2>/dev/null | head -1 | cut -d'|' -f1`
while [[ -n "$pkg" && "$pkg" != "eups" ]]; do
    unsetup $pkg > /dev/null 2>&1
    pkg=`eups list -s --topological -D --raw 2>/dev/null | head -1 | cut -d'|' -f1`
done

# clean out the path, removing EUPS_DIR/bin
# https://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
# we are not using the function below because this seems to mess with conda's
# own path manipulations
WORK=:$PATH:
REMOVE=":${EUPS_DIR}/bin:"
WORK=${WORK//$REMOVE/:}
WORK=${WORK%:}
WORK=${WORK#:}
export PATH=$WORK

# remove EUPS vars
for var in EUPS_PATH EUPS_SHELL SETUP_EUPS EUPS_DIR EUPS_PKGROOT; do
    unset $var
done
unset -f setup
unset -f unsetup
