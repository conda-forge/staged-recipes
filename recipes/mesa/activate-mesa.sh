# There is an old bug when using Mesa with Xlib instead of DRI,
# which apparently was never fixed:
# https://bugzilla.redhat.com/show_bug.cgi?id=589802
# https://lists.freedesktop.org/archives/mesa-dev/2010-May/000618.html
if [ ! -z "$XLIB_SKIP_ARGB_VISUALS" ]; then
    XLIB_SKIP_ARGB_VISUALS_BACKUP="$XLIB_SKIP_ARGB_VISUALS"
fi
export XLIB_SKIP_ARGB_VISUALS=1
