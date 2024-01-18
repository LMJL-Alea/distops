# distops 0.0.9000

## Features

* Provides functions 
[`use_distops()`](https://lmjl-alea.github.io/distops/reference/use_distops.html) 
and 
[`use_distance()`](https://lmjl-alea.github.io/distops/reference/use_distance.html) 
for package developers to define TBB-parallelized functions to compute pairwise 
distance matrices using a custom C++-implemented distance function.
* Provides subset operator 
[`[.dist`](https://lmjl-alea.github.io/distops/reference/sub-.dist.html) to 
subset a distance matrix. The returned object is an object of class `subdist` 
which can be turned into a matrix by 
[`as.matrix.subdist()`](https://lmjl-alea.github.io/distops/reference/as.matrix_subdist.html).

## ToDo List

* Pass a list instead of a matrix to be more general.
* Use Arrow parquet format to store distance matrix in multiple files when 
sample size exceeds 10,000 or something like that.
* Use Arrow connection to read in large data.
* Add Progress bar.
