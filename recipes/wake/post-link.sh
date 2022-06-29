#!/usr/bin/env bash

if [[ -n "$PREFIX" ]]; then
    # if PREFIX is set then we're running as part of conda and we shouldn't
    # output anything except to $PREFIX/.messages.txt.  see bottom of:
    # https://docs.conda.io/projects/conda-build/en/latest/resources/link-scripts.html
    exec >$PREFIX/.messages.txt 2>&1 
fi

header="You have successfully installed $PKG_NAME v$PKG_VERSION-$PKG_BUILDNUM."
die() {
    # we don't want to cause the install to fail, ever, so we always exit 0
    # with a message
    echo =============================================================
    echo
    echo $header
    echo
    echo -e "$@"
    echo
    echo =============================================================
    exit 0
}

type lsmod >/dev/null || die "However, I'm unable to check for FUSE without 'lsmod'\n" \
                             "Make sure you have installed FUSE"

lsmod | grep '^fuse' >/dev/null || die "However, it looks like you need to 'sudo modprobe fuse'\n" \
			               "Make sure you have installed FUSE and it is running"

nspath=/proc/sys/user/max_user_namespaces
if [[ -f "$nspath" ]]; then
    max_user_namespaces="$(cat $nspath)"
    if [[ "$max_user_namespaces" -eq 0 ]]; then
	die "However, $nspath says user namespaces are not enabled.\n" \
	    "You need to enable them for $PKG_NAME to work"
    fi
else
    die "However, I'm unable to check that \$(cat $nspath) is nonzero\n" \
	"$nspath does not exist.\n" \
	"Make sure that you have user namespaces enabled."
fi
