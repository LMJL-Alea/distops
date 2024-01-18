#include <distops.h>

//' @name {{{ DistanceName }}}DistanceClass
//' @title Encapsulates the {{{ DistanceName }}} distance operation
//' @description This class encapsulates the {{{ DistanceName }}} distance
//'   operation for seamless integration with the **RcppParallel** and
//'   **distops** packages.
//' @field new Constructor.
//'  - `inputMatrix`: The input matrix to read the data from;
//'  - `outputMatrix`: The output matrix to write the distance matrix to.
//' @field operator() Function call operator which computes the pairwise
//'   {{{ DistanceName }}} distance of a given chunk of the data sample.
//'   - `begin`: The index of the first element in the chunk;
//'   - `end`: The index of the last element in the chunk.
//' @keywords internal
struct {{{ DistanceName }}}DistanceClass : public RcppParallel::Worker {

  // input matrix to read from
  const RcppParallel::RMatrix<double> m_InputMatrix;

  // output matrix to write to
  RcppParallel::RVector<double> m_OutputMatrix;

  // initialize from Rcpp input and output matrixes (the RMatrix class
  // can be automatically converted to from the Rcpp matrix type)
  {{{ DistanceName }}}DistanceClass(const Rcpp::NumericMatrix inputMatrix, Rcpp::NumericVector outputMatrix)
    : m_InputMatrix(inputMatrix), m_OutputMatrix(outputMatrix) {}

  // function call operator that work for the specified range (begin/end)
  void operator()(std::size_t begin, std::size_t end) {
    unsigned int N = m_InputMatrix.nrow();
    unsigned int P = m_InputMatrix.ncol();
    for (std::size_t k = begin; k < end; ++k)
    {
      // https://stackoverflow.com/questions/27086195/linear-index-upper-triangular-matrix
      unsigned int i = N - 2 - std::floor(std::sqrt(-8 * k + 4 * N * (N - 1) - 7) / 2.0 - 0.5);
      unsigned int j = k + i + 1 - N * (N - 1) / 2 + (N - i) * ((N - i) - 1) / 2;

      // BEGIN USER CODE HERE: Please replace
      double distanceValue = 0.0;
      // END USER CODE

      m_OutputMatrix[k] = distanceValue;
    }
  }
};

// [[Rcpp::export]]
Rcpp::NumericVector Get{{{ DistanceName }}}DistanceMatrix(Rcpp::NumericMatrix& x)
{
  return distops::GetDistanceMatrix<{{{ DistanceName }}}DistanceClass>(x);
}
