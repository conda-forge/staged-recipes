#set -ex
#sleep 0
#echo "=============== PPR install $VDF_MODE"
set -ex
python -m pip install --progress-bar off --quiet --no-input --no-deps "." -vv

