@echo off

idoc2smv                                       ^
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT  ^
    "%PREFIX%\share\microed-data\movie23.idoc"
(
    echo 7018e62b3e52122ae3be875642f33bad  t_001.img
) | sed -e "s/[[:space:]]*$//" | md5sum -c -
if errorlevel 1 exit /b 1

tiff2smv                                          ^
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT     ^
    "%PREFIX%\share\microed-data\movie23_000.tif"
(
    echo 9f01e41a1e01ad59668450160c873214  t_001.img
) | sed -e "s/[[:space:]]*$//" | md5sum -c -
if errorlevel 1 exit /b 1

tvips2smv                                           ^
    -f -g 5 -o "t_###.img" -r 0.09 -z EST5EDT       ^
    "%PREFIX%\share\microed-data\movie23_000.tvips"
(
    echo 03232857ed7ce025016d94343719ac98  t_001.img
    echo a23a49265bbca8d6996dc0e06aeb808b  t_002.img
) | sed -e "s/[[:space:]]*$//" | md5sum -c -
if errorlevel 1 exit /b 1
