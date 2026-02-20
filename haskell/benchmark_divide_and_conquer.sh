echo "input,cores,chunk_size,divider,runk1,runk2,runk3,runk4,runk5" > runtime_dnc_haskell.csv
for inputSize in 15000 30000 100000
do
    for cores in 1 2 4 8 16 32 64
    do
        for chunk_size in 1 50 100 500 1000 2000
        do
            for divider in 2 4 8 16
            do
                echo -n $inputSize >> runtime_dnc_haskell.csv
                echo -n "," >> runtime_dnc_haskell.csv
                echo -n $cores >> runtime_dnc_haskell.csv
                echo -n "," >> runtime_dnc_haskell.csv
                echo -n $chunk_size >> runtime_dnc_haskell.csv
                echo -n "," >> runtime_dnc_haskell.csv
                echo -n $divider >> runtime_dnc_haskell.csv
                for k in 1 2 3 4 5
                do
                    echo -n "," >> runtime_dnc_haskell.csv
                    printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize -k $chunk_size $divider +RTS -N$cores)" >> runtime_dnc_haskell.csv
                    # printf "%s" "$(cabal exec -- haskell-totient 1 $inputSize -k $chunk_size $divider +RTS -N$cores)" >> runtime_dnc_haskell.csv
                done
                echo "" >> runtime_dnc_haskell.csv
            done
        done
    done
done
