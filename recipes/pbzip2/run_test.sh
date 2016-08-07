# compare pbzip2's output against output from bzip2 1.0.6
echo "uncompressed" | pbzip2 -c > pbzip2.out
dd if=pbzip2.out ibs=1 skip=10 count=4 2>/dev/null > pbzip2.crc
[[ $(hexdump -e '1/1 "%02x"' pbzip2.crc) == "6a8eb39c" ]] || exit 1
