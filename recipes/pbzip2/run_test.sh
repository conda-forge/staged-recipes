# compare pbzip2's output against output from bzip2 1.0.6
echo "uncompressed" | pbzip2 -c > pbzip2.out
[[ $(md5sum pbzip2.out) == "26bef035e3983d8817dcc041723d1b28  pbzip2.out" ]] || exit 1
