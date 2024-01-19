#include <Rcpp.h>
#include <RcppParallel.h>
#include <limits>

struct MedoidFinder : public RcppParallel::Worker
{
  // input distances
  const RcppParallel::RVector<double> m_DistanceValues;

  // medoid
  unsigned int m_MedoidValue;

  // accumulated distance of the medoid
  double m_SumOfDistances;

  // constructors
  MedoidFinder(const Rcpp::NumericVector input)
    : m_DistanceValues(input),
      m_MedoidValue(0),
      m_SumOfDistances(std::numeric_limits<double>::infinity()) {}
  MedoidFinder(const MedoidFinder& medoidFinder, RcppParallel::Split)
    : m_DistanceValues(medoidFinder.m_DistanceValues),
      m_MedoidValue(0),
      m_SumOfDistances(std::numeric_limits<double>::infinity()) {}

  // find medoid on just the element of the range I've been asked to
  void operator()(std::size_t begin, std::size_t end) {
    unsigned int numberOfDistanceValues = m_DistanceValues.size();
    unsigned int numberOfObservations = (1 + std::sqrt(1 + 8 * numberOfDistanceValues)) / 2;

    for (unsigned int observationIndex = begin; observationIndex < end; ++observationIndex)
    {
      double distanceSum = 0.0;
      for (unsigned int otherObservationIndex = 0; otherObservationIndex < numberOfObservations; ++otherObservationIndex)
      {
        if (observationIndex == otherObservationIndex)
          continue;

        unsigned int rowId = observationIndex + 1;
        unsigned int columnId = otherObservationIndex + 1;
        if (rowId > columnId)
        {
          unsigned int temp = rowId;
          rowId = columnId;
          columnId = temp;
        }
        unsigned int distanceIndex = numberOfObservations * (rowId - 1) -
          rowId * (rowId - 1) / 2 + columnId - rowId - 1;
        distanceSum += m_DistanceValues[distanceIndex];
      }

      if (distanceSum < m_SumOfDistances)
      {
        m_SumOfDistances = distanceSum;
        m_MedoidValue = observationIndex + 1;
      }
    }
  }

  // join my values with that of another MedoidFinder
  void join(const MedoidFinder& rhs) {
    if (rhs.m_SumOfDistances < m_SumOfDistances)
    {
      m_SumOfDistances = rhs.m_SumOfDistances;
      m_MedoidValue = rhs.m_MedoidValue;
    }
  }
};

// [[Rcpp::export]]
unsigned int GetMedoid(const Rcpp::NumericVector& distanceValues)
{
  MedoidFinder medoidFinder(distanceValues);
  RcppParallel::parallelReduce(0, distanceValues.attr("Size"), medoidFinder);
  return medoidFinder.m_MedoidValue;
}

struct MultipleMedoidFinder : public RcppParallel::Worker
{
  // input distances
  const RcppParallel::RVector<double> m_DistanceValues;

  // input groups
  const RcppParallel::RVector<int> m_GroupingValues;

  // input group ID
  const unsigned int m_GroupId;

  // medoid
  unsigned int m_MedoidValue;

  // accumulated distance of the medoid
  double m_SumOfDistances;

  // constructors
  MultipleMedoidFinder(const Rcpp::NumericVector& input,
                       const Rcpp::IntegerVector& grouping,
                       const unsigned int groupId)
    : m_DistanceValues(input),
      m_GroupingValues(grouping),
      m_GroupId(groupId),
      m_MedoidValue(0),
      m_SumOfDistances(std::numeric_limits<double>::infinity()) {}
  MultipleMedoidFinder(const MultipleMedoidFinder& medoidFinder, RcppParallel::Split)
    : m_DistanceValues(medoidFinder.m_DistanceValues),
      m_GroupingValues(medoidFinder.m_GroupingValues),
      m_GroupId(medoidFinder.m_GroupId),
      m_MedoidValue(0),
      m_SumOfDistances(std::numeric_limits<double>::infinity()) {}

  // find medoid on just the element of the range I've been asked to
  void operator()(std::size_t begin, std::size_t end) {
    unsigned int numberOfObservations = m_GroupingValues.size();

    for (unsigned int observationIndex = begin; observationIndex < end; ++observationIndex)
    {
      unsigned int observationGroupId = m_GroupingValues[observationIndex];
      if (observationGroupId != m_GroupId)
        continue;

      double distanceSum = 0.0;
      for (unsigned int otherObservationIndex = 0; otherObservationIndex < numberOfObservations; ++otherObservationIndex)
      {
        unsigned int otherObservationGroupId = m_GroupingValues[otherObservationIndex];
        if (otherObservationGroupId != m_GroupId)
          continue;

        if (observationIndex == otherObservationIndex)
          continue;

        unsigned int rowId = observationIndex + 1;
        unsigned int columnId = otherObservationIndex + 1;
        if (rowId > columnId)
        {
          unsigned int temp = rowId;
          rowId = columnId;
          columnId = temp;
        }
        unsigned int distanceIndex = numberOfObservations * (rowId - 1) -
          rowId * (rowId - 1) / 2 + columnId - rowId - 1;
        distanceSum += m_DistanceValues[distanceIndex];
      }

      if (distanceSum < m_SumOfDistances)
      {
        m_SumOfDistances = distanceSum;
        m_MedoidValue = observationIndex + 1;
      }
    }
  }

  // join my values with that of another MedoidFinder
  void join(const MultipleMedoidFinder& rhs) {
    if (rhs.m_SumOfDistances < m_SumOfDistances)
    {
      m_SumOfDistances = rhs.m_SumOfDistances;
      m_MedoidValue = rhs.m_MedoidValue;
    }
  }
};

// [[Rcpp::export]]
Rcpp::IntegerVector GetMedoids(const Rcpp::NumericVector& distanceValues,
                               const Rcpp::IntegerVector& groupingValues)
{
  Rcpp::IntegerVector groupIds = Rcpp::sort_unique(groupingValues);
  unsigned int numberOfGroups = groupIds.size();
  unsigned int numberOfObservations = distanceValues.attr("Size");
  Rcpp::IntegerVector medoids(numberOfGroups);

  for (unsigned int groupIndex = 0; groupIndex < numberOfGroups; ++groupIndex)
  {
    unsigned int groupId = groupIds[groupIndex];
    MultipleMedoidFinder medoidFinder(distanceValues, groupingValues, groupId);
    RcppParallel::parallelReduce(0, numberOfObservations, medoidFinder);
    medoids[groupIndex] = medoidFinder.m_MedoidValue;
  }

  return medoids;
}
