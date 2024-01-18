#ifndef __DISTOPS_H__
#define __DISTOPS_H__

#include <RcppParallel.h>
#include <Rcpp.h>

namespace distops {

  template <typename DistanceFunction>
  inline Rcpp::NumericVector GetDistanceMatrix(const Rcpp::NumericMatrix& x)
  {
    // allocate the matrix we will return
    unsigned int inputSize = x.nrow();
    unsigned int outputSize = inputSize * (inputSize - 1) / 2;
    Rcpp::NumericVector y(outputSize);

    // create the worker
    DistanceFunction distFunc(x, y);

    // call it with parallelFor
    RcppParallel::parallelFor(0, outputSize, distFunc);

    return y;
  }
}

#endif // __DISTOPS_H__
