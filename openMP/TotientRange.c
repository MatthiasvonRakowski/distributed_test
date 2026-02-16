
// TotientRance.c - Sequential Euler Totient Function (C Version)
// compile: gcc -Wall -O -o TotientRange TotientRange.c
// run:     ./TotientRange lower_num uppper_num

// sum of the totients bwt lower and upper limit using C longs. 

// * gcc-15 -Wall -O2 -fopenmp TotientRange.c -o totient


// * φ(n) = nb d’entiers entre 1 et n qui sont premiers avec n (copremiers)

#define _GNU_source
#include <stdio.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <omp.h>  //*


typedef struct data_info_s {
  long lower, upper;
  bool is_euler_paralellised, is_sum_totient_paralellised;
  bool is_euler_guided, is_sum_totient_guided;
  bool is_naive_parallelised, is_skeleton_parallelised;
  int chunk_size_limit, dividier;
  int chunk_size_euler, chunk_size_sum_totient;
  int number_core_euler, number_core_sum_totient;
} data_info_t;

// // PGCD
long hcf(long x, long y)
{
  long t;
  while (y != 0) {
    t = x % y;
    x = y;
    y = t;
  }
  return x;
}

// // COPREMIERS
int relprime(long x, long y)
{
  return hcf(x, y) == 1;
}

// euler -> fct φ(n)
// ! EULER
long euler(long n, bool is_parallelised, data_info_t *run_info)
{
  long length = 0; //*
  if (is_parallelised) {
    if (run_info->is_euler_guided){
      #pragma omp parallel for schedule(guided, run_info->chunk_size_euler) reduction(+:length) //*
      for (long i = 1; i <= n; i++) 
        if (relprime(n, i))
          length++;
    } else {
      #pragma omp parallel for schedule(dynamic, run_info->chunk_size_euler) reduction(+:length) //*
      for (long i = 1; i <= n; i++) 
        if (relprime(n, i))
          length++;
      } 
  } else {
    // not parallel version
    for (long i = 1; i <= n; i++) 
      if (relprime(n, i))
        length++;
    }
  return length;
}


long sumTotient_divide_conquer(long lower, long upper, data_info_t *run_info) {
  long range = upper - lower;
  long mid = lower + range / run_info->dividier;
  long x = 0, y = 0;
  long local_sum = 0;
  
  if (range <= run_info->chunk_size_limit) {
    for (long i = lower; i <= upper; i++) {
      local_sum += euler(i, run_info->is_euler_paralellised, run_info);
    }
    return local_sum;
  }
  
  #pragma omp task shared(x)
  {
    x = sumTotient_divide_conquer(lower, mid, run_info);
  }
  
  #pragma omp task shared(y)
  {
    y = sumTotient_divide_conquer(mid + 1, upper, run_info);
  }
  
  #pragma omp taskwait
  return x + y;
}

long sumTotient_skeleton(data_info_t *run_info) {
  long total_sum = 0;

  #pragma omp parallel
  {
    #pragma omp single
    {
      total_sum = sumTotient_divide_conquer(run_info->lower, run_info->upper, run_info);
    }
  }

  return total_sum;
}


// sumTotient -> somme des φ
// ! SOMME DES EULER
long sumTotient(data_info_t *run_info)
{
    long sum = 0;

    if (run_info->is_skeleton_parallelised)
      return sumTotient_skeleton(run_info);

    if (run_info->is_sum_totient_paralellised) {
      if (run_info->is_sum_totient_guided){
        #pragma omp parallel for schedule(guided, run_info->chunk_size_sum_totient) reduction(+:sum)
        for (long i = run_info->lower; i <= run_info->upper; i++) 
          sum += euler(i,run_info->is_sum_totient_paralellised, run_info);

      }else{
        #pragma omp parallel for schedule(dynamic, run_info->chunk_size_sum_totient) reduction(+:sum)
        for (long i = run_info->lower; i <= run_info->upper; i++)
          sum += euler(i,run_info->is_sum_totient_paralellised, run_info);
      }
    } else if (run_info->is_naive_parallelised) {
      #pragma omp parallel for schedule(static) reduction(+:sum) 
      for (long i = run_info->lower; i <= run_info->upper; i++)
        sum += euler(i, false, run_info);
    } else {
      // not parallel version
        for (long i = run_info->lower; i <= run_info->upper; i++) 
          sum += euler(i, run_info->is_sum_totient_paralellised, run_info);
    }
  
    return sum;
  }

int assigned_specificity(char **argv, int argc, int i, data_info_t *run_info)
{
  if (argc < i + 3) {
    fprintf(stderr, "%s", "ERROR: must have 4 arguments following a '-e' or '-s' and in the form number number 'TRUE or FALSE'\n");
    exit(1);
  }
  if (!strcmp(argv[i], "-e")) {
    run_info->is_euler_paralellised = true;

    sscanf(argv[++i], "%d", &run_info->number_core_euler);
    sscanf(argv[++i], "%d", &run_info->chunk_size_euler);
    run_info->is_euler_guided = (!strcmp(argv[++i], "TRUE")?true:false);
  } else {
    run_info->is_sum_totient_paralellised = true;
    
    sscanf(argv[++i], "%d", &run_info->number_core_sum_totient);
    sscanf(argv[++i], "%d", &run_info->chunk_size_sum_totient);
    run_info->is_sum_totient_guided = (!strcmp(argv[++i], "TRUE")?true:false);
  }
  return i;
}

data_info_t *init_run(int argc, char **argv)
{
  data_info_t *run_info = malloc(sizeof(data_info_t));

  if (argc < 3) {
    fprintf(stderr, "%s", "ERROR: to see the usage make ./totient -h or ./totient --help\n");
    exit(1);
  }
  
  sscanf(argv[1], "%ld", &run_info->lower);
  sscanf(argv[2], "%ld", &run_info->upper);
  run_info->number_core_euler = 0;
  run_info->chunk_size_euler = 0;
  run_info->number_core_sum_totient = 0;
  run_info->chunk_size_sum_totient = 0;
  run_info->chunk_size_limit = 0;
  run_info->is_euler_paralellised = false;
  run_info->is_euler_guided = false;
  run_info->is_sum_totient_paralellised = false;
  run_info->is_sum_totient_guided = false;
  run_info->is_naive_parallelised = false;
  run_info->is_skeleton_parallelised = false;
  run_info->dividier = 2;

  
  for (int i = 3; i < argc; i++) {
    if (argv[i]) {
      if (strlen(argv[i]) != 2) {
        continue;
      }
      switch (argv[i][1]) {
        case 'e':
        i = assigned_specificity(argv, argc, i, run_info);
        break;
        case 's':
        i = assigned_specificity(argv, argc, i, run_info);
        break;
        case 'n':
        run_info->is_naive_parallelised = true;
        break;
        case 'k':
        run_info->is_skeleton_parallelised = true;
        sscanf(argv[++i], "%d", &run_info->chunk_size_limit);
        sscanf(argv[++i], "%d", &run_info->dividier);
        break;
        default:
        break;
      }
    }
  }

  // avoid having any issue with chunk_size = 0 or number_core_sum_totient = 0
  run_info->dividier = (run_info->dividier <= 2) ? 2 : run_info->dividier;
  run_info->number_core_euler = (run_info->number_core_euler) ? run_info->number_core_euler : 1;
  run_info->chunk_size_euler = (run_info->chunk_size_euler) ? run_info->chunk_size_euler : 1;
  run_info->number_core_sum_totient = (run_info->number_core_sum_totient) ? run_info->number_core_sum_totient : 1;
  run_info->chunk_size_sum_totient = (run_info->chunk_size_sum_totient) ? run_info->chunk_size_sum_totient : 1;

  return run_info;
}

void runBenchmark(data_info_t *run_info)
{
  double start, end; //*
  double time_taken;

  for (long i = 1; i < 10000000 ; i = i + 1000000) {
    start = omp_get_wtime(); //*
    sumTotient(run_info);
    end = omp_get_wtime();
    //time_taken = (end - start) / CLOCKS_PER_SEC;      
    time_taken = ((double) (end - start)); // ->ticks par seconde
    printf("sumTotient(%lu) = %f seconds\n", i, time_taken);
  }   
}

void help(void)
{
  printf("there\n");
  printf(
      "USAGE:\n"
      " ./totient <lower> <upper> "
      "[-e <cores> <chunk> <TRUE|FALSE>] "
      "[-s <cores> <chunk> <TRUE|FALSE>]\n\n"

      "DESCRIPTION:\n"
      " <lower> <upper>\n"
      "   Inclusive range of integers to process.\n\n"

      " -e <cores> <chunk> <TRUE|FALSE>\n"
      "   Enable parallel Euler totient computation.\n"
      "   <cores>  Number of OpenMP threads.\n"
      "   <chunk>  Scheduling chunk size.\n"
      "   TRUE     Use guided scheduling.\n"
      "   FALSE    Use dynamic scheduling.\n\n"
      
      " -s <cores> <chunk> <TRUE|FALSE>\n"
      "   Enable parallel sum of totients computation.\n\n"

      " -h\n"
      "   Display this help message and exit.\n\n"

      "EXAMPLES:\n"
      " ./totient 1 100000\n"
      " ./totient 1 100000 -e 8 100 TRUE\n"
      " ./totient 1 100000 -e 8 100 FALSE -s 4 500 TRUE\n");
  exit(0);
}

int main(int argc, char ** argv)
{
  data_info_t *run_info;
  
  if (argc == 2 && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))) {
    help();
  }
  run_info = init_run(argc, argv);
  
  // runBenchmark(run_info);
  double start = omp_get_wtime();
  sumTotient(run_info);
  double end = omp_get_wtime();
  printf("%f\n", end - start);
  return 0;
  }
