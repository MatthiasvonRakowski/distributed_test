# If you are collecting data for the coursework, you should run this
# script on the head node on the cluster.

echo "input,cores,chunk_size,divider,runk1,runk2,runk3,runk4,runk5" > runtime.csv
for inputSize in 15000 30000 100000
do
    for cores in 1 2 8 16 28 36 44 56 60 64
    do
        for chunk_size in 1 50 100 200 5000 1000 2000
        do
            for divider in 1 2 4 8 10 12 16
            do
                echo -n $inputSize >> runtime.csv
                echo -n "," >> runtime.csv
                echo -n $cores >> runtime.csv
                echo -n "," >> runtime.csv
                echo -n $chunk_size >> runtime.csv
                echo -n "," >> runtime.csv
                echo -n $divider >> runtime.csv
                for k in 1 2 3 4 5
                do
                    echo -n "," >> runtime.csv
                    # to test on any computer (e.g. in EM 2.50 or your laptop)
                    # printf "%s" "$(./totient 1 $inputSize -k $divider $chunk_size)" >> runtime.csv
                    printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores ./totient 1 $inputSize -k $divider $chunk_size)" >> runtime.csv
                    # printf "%s" "$(./totient 1 $inputSize -s $((cores / 4 + 1)) $chunk_size TRUE -e $((cores / 5 + 1)) $chunk_size TRUE +RTS -N$cores)" >> runtime.csv
                    # printf "%s" "$(./totient 1 $inputSize -s $((cores / 4 + 1)) $chunk_size TRUE -e $((cores / 5 + 1)) $chunk_size TRUE +RTS -N$cores)" >> runtime.csv
                    # to test on a Robotarium cluster compute node
                    # printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores ./totient 1 $inputSize +RTS -N$cores)" >> runtime.csv
                done
                echo "" >> runtime.csv
            done
        done
    done
done
