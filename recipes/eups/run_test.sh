#!/bin/bash
echo " -------------------------------------------------------------------------------------"
echo "eups runs:"
eups -h || exit 1
echo -e "\neups list:"
eups list || exit 1
