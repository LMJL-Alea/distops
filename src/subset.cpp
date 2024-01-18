#include <Rcpp.h>

// [[Rcpp::export]]
Rcpp::NumericVector DiagonalSubsetter(const Rcpp::NumericVector& x,
                                      const Rcpp::IntegerVector& indices)
{
  unsigned int numberOfInputObservations = x.attr("Size");
  unsigned int numberOfOutputObservations = indices.size();
  unsigned int numberOfOutputValues = numberOfOutputObservations *
    (numberOfOutputObservations - 1) / 2;

  Rcpp::NumericVector result(numberOfOutputValues);
  for (unsigned int outputLinearId = 0; outputLinearId < numberOfOutputValues; ++outputLinearId)
  {
    // https://stackoverflow.com/questions/27086195/linear-index-upper-triangular-matrix
    unsigned int outputRowId = numberOfOutputObservations - 2 -
      std::floor(std::sqrt(-8 * outputLinearId + 4 * numberOfOutputObservations *
      (numberOfOutputObservations - 1) - 7) / 2.0 - 0.5);
    unsigned int outputColumnId = outputLinearId + outputRowId + 1 -
      numberOfOutputObservations * (numberOfOutputObservations - 1) / 2 +
      (numberOfOutputObservations - outputRowId) *
      ((numberOfOutputObservations - outputRowId) - 1) / 2;
    unsigned int inputRowId = indices[outputRowId];
    unsigned int inputColumnId = indices[outputColumnId];
    if (inputRowId > inputColumnId)
    {
      unsigned int temp = inputRowId;
      inputRowId = inputColumnId;
      inputColumnId = temp;
    }
    unsigned int inputLinearId = numberOfInputObservations * (inputRowId - 1) -
      inputRowId * (inputRowId - 1) / 2 + inputColumnId - inputRowId - 1;
    result(outputLinearId) = x(inputLinearId);
  }

  return result;
}

// [[Rcpp::export]]
Rcpp::NumericMatrix OffDiagonalSubsetter(const Rcpp::NumericVector& x,
                                         const Rcpp::IntegerVector& row_indices,
                                         const Rcpp::IntegerVector& col_indices)
{
  unsigned int numberOfOutputRows = row_indices.size();
  unsigned int numberOfOutputColumns = col_indices.size();
  unsigned int numberOfOutputValues = numberOfOutputRows * numberOfOutputColumns;
  unsigned int numberOfInputObservations = x.attr("Size");

  Rcpp::NumericMatrix result(numberOfOutputRows, numberOfOutputColumns);
  for (unsigned int outputLinearId = 0; outputLinearId < numberOfOutputValues; ++outputLinearId)
  {
    unsigned int outputRowId = outputLinearId % numberOfOutputRows;
    unsigned int outputColumnId = outputLinearId / numberOfOutputRows;
    unsigned int inputRowId = row_indices[outputRowId];
    unsigned int inputColumnId = col_indices[outputColumnId];
    if (inputRowId > inputColumnId)
    {
      unsigned int temp = inputRowId;
      inputRowId = inputColumnId;
      inputColumnId = temp;
    }
    unsigned int inputLinearId = numberOfInputObservations * (inputRowId - 1) -
      inputRowId * (inputRowId - 1) / 2 + inputColumnId - inputRowId - 1;
    result(outputRowId, outputColumnId) = x(inputLinearId);
  }

  return result;
}
