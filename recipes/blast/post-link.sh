echo "Succesfully installed blast." > $PREFIX/.messages.txt
echo "Now, either re-activate your environment or manually set environment variable BLASTMAT to $PREFIX/share/blast-2.2.26/data/." >> $PREFIX/.messages.txt
echo "In bash: export BLASTMAT=$PREFIX/share/blast-2.2.26/data/" >> $PREFIX/.messages.txt
