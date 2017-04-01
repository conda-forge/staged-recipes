#!/bin/bash

set +x

if [[ -n "$TERM" && "$TERM" != dumb ]]; then
    txtund=$(tput sgr 0 1)          # underline
    txtbld=$(tput bold)             # bold
    bldred=${txtbld}$(tput setaf 1) # red
    bldgre=${txtbld}$(tput setaf 2) # green
    bldyel=${txtbld}$(tput setaf 3) # yellow
    bldblu=${txtbld}$(tput setaf 4) # blue
    txtcya=$(tput setaf 6)          # cyan
    bldwht=${txtbld}$(tput setaf 7) # white
    txtrst=$(tput sgr0)             # reset
fi

ERROR=0
SUCCESS=0



pidof() {
    local pids=$(ps axc | awk "{if (\$5==\"$1\") print \$1}" | tr '\n' ' ')
    if [[ -n $pids ]]; then
        echo "$pids"
    else
        return 1;
    fi
}

die() {
    sleep 3
    pidof nginx && killall nginx
    sleep 1
    pidof nginx && killall -9 nginx
    echo -e "$@"
}


http_test() {
    URL=$1
    UPID=`pidof nginx`
    if [ "$UPID" != "" ]; then
        echo -e "${bldgre}>>> Spawned PID $UPID, running tests${txtrst}"
        sleep 5
        curl -fI $URL
        RET=$?
        if [ $RET != 0 ]; then
            die "${bldred}>>> Error during curl run${txtrst}"
            ERROR=$((ERROR+1))
        else
            SUCCESS=$((SUCCESS+1))
        fi
        die "${bldyel}>>> SUCCESS: Done${txtrst}"
    else
        die "${bldred}>>> ERROR: nginx did not start${txtrst}"
        ERROR=$((ERROR+1))
    fi
}


test_nginx_process() {
    echo -e "${bldyel}================== TESTING =====================${txtrst}"
    echo -e "${bldyel}>>> Spawning nginx${txtrst}"
    echo -en "${bldred}"
    $PREFIX/bin/nginx
    echo -en "${txtrst}"

    http_test "http://localhost:8080/"

    echo -e "${bldyel}===================== DONE =====================${txtrst}\n\n"

}


nginx -V
nginx -t


if [[ $(uname -s) == Linux ]]; then
    test_nginx_process
fi

if [ $ERROR -ge 1 ]; then
    echo "${bldred}>>> $ERROR FAILED${txtrst}"
    set -x
    exit 1
fi

echo "${bldgre}>>> $SUCCESS SUCCESSFUL${txtrst}"
set -x
exit 0
