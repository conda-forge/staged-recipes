#! /bin/sh

idoc2smv                                      \
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT \
    "${SRC_DIR}/test/movie23.idoc"
cat << EOF | md5sum -c -
7018e62b3e52122ae3be875642f33bad  t_001.img
EOF

tiff2smv                                      \
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT \
    "${SRC_DIR}/test/movie23_000.tif"
cat << EOF | md5sum -c -
9f01e41a1e01ad59668450160c873214  t_001.img
EOF

tvips2smv                                     \
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT \
    "${SRC_DIR}/test/movie23_000.tvips"
cat << EOF | md5sum -c -
03232857ed7ce025016d94343719ac98  t_001.img
a23a49265bbca8d6996dc0e06aeb808b  t_002.img
EOF
