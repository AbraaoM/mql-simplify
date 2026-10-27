//+------------------------------------------------------------------+
//|                                                   Regression.mqh |
//|  Ordinary least squares on a price window, plus the residual     |
//|  standard deviation (regression channel). Pure functions, no     |
//|  trade code, no terminal calls: safe in indicators and testable  |
//|  in a script.                                                    |
//|                                                                  |
//|  Convention: values[] is in chronological order (index 0 = the   |
//|  oldest value), the same order CopyClose() returns when the      |
//|  array is not a series. x = 0 .. count-1, so the "last" fitted   |
//|  value is the regression line at the newest bar of the window.   |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_REGRESSION_MQH
#define MQL_SIMPLIFY_REGRESSION_MQH

struct SimplifyLinRegResult {
  bool               ok;         // false: count < 2, window out of range or flat x
  int                count;      // points used
  double             slope;      // price change per bar
  double             intercept;  // fitted value at x = 0 (oldest bar of the window)
  double             last;       // fitted value at x = count-1 (newest bar)
  double             stdev;      // residual standard deviation (population, divides by n)
  double             r2;         // coefficient of determination, 0..1 (0 when y is flat)
};

//+------------------------------------------------------------------+
//|  Fits values[start .. start+count-1]. Returns r.ok.              |
//+------------------------------------------------------------------+
bool SimplifyLinReg(const double &values[], const int start, const int count,
                    SimplifyLinRegResult &r) {
  r.ok = false; r.count = 0; r.slope = 0; r.intercept = 0; r.last = 0; r.stdev = 0; r.r2 = 0;
  int size = ArraySize(values);
  if(count < 2 || start < 0 || start + count > size)
    return false;
  double n = (double)count;
  double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
  for(int i = 0; i < count; i++) {
    double y = values[start + i];
    sumX += i; sumY += y; sumXY += i * y; sumXX += (double)i * i;
  }
  double den = n * sumXX - sumX * sumX;
  if(den == 0)
    return false;
  r.slope = (n * sumXY - sumX * sumY) / den;
  r.intercept = (sumY - r.slope * sumX) / n;
  r.last = r.intercept + r.slope * (count - 1);
  double meanY = sumY / n, ssRes = 0, ssTot = 0;
  for(int i = 0; i < count; i++) {
    double y = values[start + i];
    double e = y - (r.intercept + r.slope * i);
    ssRes += e * e;
    ssTot += (y - meanY) * (y - meanY);
  }
  r.stdev = MathSqrt(ssRes / n);
  r.r2 = (ssTot > 0) ? MathMax(0.0, 1.0 - ssRes / ssTot) : 0;
  r.count = count;
  r.ok = true;
  return true;
}

//+------------------------------------------------------------------+
//|  Fits the newest `count` values of the array (the window ends at |
//|  the last element).                                              |
//+------------------------------------------------------------------+
bool SimplifyLinRegLast(const double &values[], const int count, SimplifyLinRegResult &r) {
  return SimplifyLinReg(values, ArraySize(values) - count, count, r);
}

//+------------------------------------------------------------------+
//|  Channel band at the newest bar: last +/- k * stdev              |
//+------------------------------------------------------------------+
double SimplifyLinRegUpper(const SimplifyLinRegResult &r, const double k) { return r.last + k * r.stdev; }
double SimplifyLinRegLower(const SimplifyLinRegResult &r, const double k) { return r.last - k * r.stdev; }

//+------------------------------------------------------------------+
//|  Slope normalised by volatility: total move of the line over the |
//|  window in units of the residual stdev. Scale-free, so the same  |
//|  threshold works on EURUSD and on gold. 0 when stdev is 0.       |
//+------------------------------------------------------------------+
double SimplifyLinRegTrendScore(const SimplifyLinRegResult &r) {
  if(!r.ok || r.stdev <= 0)
    return 0;
  return r.slope * (r.count - 1) / r.stdev;
}

#endif
