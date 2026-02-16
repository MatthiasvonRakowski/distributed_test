# If you are collecting data for the coursework, you should run this
# script on the head node on the cluster.

echo "input,cores,run1n,run2n,run3n,run4n,run5n" > runtime.csv
for inputSize in 15000 30000 100000
do
    echo -n $inputSize >> runtime.csv
    echo -n "," >> runtime.csv
    for k in 1 2 3 4 5
    do
        echo -n "," >> runtime.csv
        # to test on any computer (e.g. in EM 2.50 or your laptop)
        printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize +RTS -N$cores)" >> runtime.csv
    done
    for k in 1 2 3
    do
        echo -n "," >> runtime.csv
        # to test on any computer (e.g. in EM 2.50 or your laptop)
    done

    echo "" >> runtime.csv
done


for inputSize in 15000 30000 100000
do
    for cores in 1 2 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64
    do 
        echo -n $inputSize >> runtime.csv
        echo -n "," >> runtime.csv
        echo -n $cores >> runtime.csv
        for k in 1 2 3 4 5
        do
            echo -n "," >> runtime.csv
            # to test on any computer (e.g. in EM 2.50 or your laptop)
            printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize -n +RTS -N$cores)" >> runtime.csv
            # printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize -s $((cores / 4 + 1)) $chunk_size TRUE -e $((cores / 5 + 1)) $chunk_size TRUE +RTS -N$cores)" >> runtime.csv
            # printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize -s $((cores / 4 + 1)) $chunk_size TRUE -e $((cores / 5 + 1)) $chunk_size TRUE +RTS -N$cores)" >> runtime.csv
            # to test on a Robotarium cluster compute node
            # printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores cabal exec -- haskell-totient 1 $inputSize +RTS -N$cores)" >> runtime.csv
        done
        echo "" >> runtime.csv
    done
done
