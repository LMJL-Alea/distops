# distops 0.1.0

## Features

* Provides functions 
[`use_distops()`](https://lmjl-alea.github.io/distops/reference/use_distops.html) 
and 
[`use_distance()`](https://lmjl-alea.github.io/distops/reference/use_distance.html) 
for package developers to define TBB-parallelized functions to compute pairwise 
distance matrices using a custom C++-implemented distance function.
* Provides subset operator 
[`[.dist`](https://lmjl-alea.github.io/distops/reference/sub-.dist.html) to 
subset a distance matrix. The returned object is either of class `dist` if both 
row and column indices are identical or of class `matrix` if both row and column 
indices are different.
* Provides function `find_medoids(D, memberships = NULL)` to find medoid(s) of a 
distance matrix. If `memberships` is provided, one medoid per cluster is 
returned. Otherwise, a single overall medoid is returned.
