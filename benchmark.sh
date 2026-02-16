cd openMP
make clean
make
./benchmark.sh
cd ..
cd haskell
cabal clean
cabal build
./benchmark.sh