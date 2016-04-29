set +x

txtund=$(tput sgr 0 1)          # underline
txtbld=$(tput bold)             # bold
bldred=${txtbld}$(tput setaf 1) # red
bldgre=${txtbld}$(tput setaf 2) # green
bldyel=${txtbld}$(tput setaf 3) # yellow
bldblu=${txtbld}$(tput setaf 4) # blue
txtcya=$(tput setaf 6)          # cyan
bldwht=${txtbld}$(tput setaf 7) # white
txtrst=$(tput sgr0)             # reset

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
    date > reload.txt
    sleep 3
    pidof uwsgi && killall uwsgi
    sleep 1
    pidof uwsgi && killall -9 uwsgi
    echo -e "$@"
    if [ -e uwsgi.log ]; then
        echo -e "${bldyel}>>> uwsgi.log:${txtrst}"
        echo -e "${txtcya}"
        cat uwsgi.log
        echo -e "${txtrst}"
    fi
}


http_test() {
    URL=$1
    UPID=`pidof uwsgi`
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
        die "${bldred}>>> ERROR: uWSGI did not start${txtrst}"
        ERROR=$((ERROR+1))
    fi
}


test_python() {
    date > reload.txt
    rm -f uwsgi.log
    echo -e "${bldyel}================== TESTING $1 =====================${txtrst}"
    echo -e "${bldyel}>>> Spawning uWSGI python app${txtrst}"
    echo -en "${bldred}"
    pushd $SRC_DIR
    $PREFIX/bin/uwsgi --master --http :8080 --exit-on-reload --touch-reload reload.txt --wsgi-file tests/staticfile.py --daemonize uwsgi.log
    echo -en "${txtrst}"
    http_test "http://localhost:8080/"
    popd
    echo -e "${bldyel}===================== DONE $1 =====================${txtrst}\n\n"
}


test_python $CONDA_PY


echo "${bldgre}>>> $SUCCESS SUCCESSFUL PLUGIN(S)${txtrst}"
if [ $ERROR -ge 1 ]; then
    echo "${bldred}>>> $ERROR FAILED PLUGIN(S)${txtrst}"
    set -x
    exit 1
fi

set -x
exit 0


