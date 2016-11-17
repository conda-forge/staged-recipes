#!/bin/bash
unset NCARG_ROOT

for variable in $(env | grep '^OLD_NCARG_'); do
    var_name=$(echo "$variable" | cut -d= -f1)
    var_value="$(echo -n "$variable" | cut -d= -f2-)"
    export ${var_name#OLD_}="${var_value}"
    unset ${var_name}
done
