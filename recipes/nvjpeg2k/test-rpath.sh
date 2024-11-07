#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

errors=""

for lib in `find ${PREFIX}/${targetsDir}/lib -type f`; do
    [[ $lib =~ \.so ]] || continue

    rpath=$(patchelf --print-rpath $lib)
    echo "$lib rpath: $rpath"
    if [[ $rpath != "\$ORIGIN" ]]; then
        errors+="$lib\n"
    elif [[ $(objdump -x ${lib} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="$lib\n"
    fi
done

if [[ $errors ]]; then
    echo "The following libraries were found with an unexpected RPATH:"
    echo -e "$errors"

    exit 1
else
    exit 0
fi
