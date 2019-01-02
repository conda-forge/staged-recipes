echo "main = putStr \"smalltest\"" > Main.hs
ghc -v -O0 -threaded -L$PREFIX/lib -fasm -o smalltest Main.hs 
./smalltest
