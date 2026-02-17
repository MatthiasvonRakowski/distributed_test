# If you are collecting data for the coursework, you should run this
# script on the head node on the cluster.

echo "input,cores,runn1,runn2,runn3,runn4,runn5" > naive_runtime.csv
for inputSize in 15000 30000 100000
do
    for cores in 1 2 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64
    do
        echo -n $inputSize >> naive_runtime.csv
        echo -n "," >> naive_runtime.csv
        echo -n $cores >> naive_runtime.csv
        for k in 1 2 3 4 5
        do
            echo -n "," >> naive_runtime.csv
            #printf "%s" "$(./totient 1 $inputSize -n)" >> naive_runtime.csv
            printf "%s" "$(srun --partition=amd-longq --cpus-per-task=$cores ./totient 1 $inputSize)" >> naive_runtime.csv
        done
        echo "" >> naive_runtime.csv
    done
done
