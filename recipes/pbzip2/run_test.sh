# compare pbzip2's output against output from bzip2 1.0.6
pbzip2 -c test_data.html > pbzip2.out
[[ $(md5sum pbzip2.out) == "bf1b17e65ecfdb7e786d0f3be8ba8382  pbzip2.out" ]]
