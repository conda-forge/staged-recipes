echo "To enable udev device setup of mirisdr hardware, you must manually install"    >> $PREFIX/.messages.txt
echo "the udev rules provided by the 'mirisdr' package by copying or linking"        >> $PREFIX/.messages.txt
echo "them into your system directory, e.g.:"                                        >> $PREFIX/.messages.txt
echo "    sudo ln -s $PREFIX/lib/udev/rules.d/mirisdr.rules /etc/udev/rules.d/"      >> $PREFIX/.messages.txt
echo "After doing this, reload your udev rules:"                                     >> $PREFIX/.messages.txt
echo "    sudo udevadm control --reload && sudo udevadm trigger"                     >> $PREFIX/.messages.txt
