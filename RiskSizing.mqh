//+------------------------------------------------------------------+
//|                                                   RiskSizing.mqh |
//|  Lot size from money at risk and stop distance, respecting the   |
//|  symbol volume min / max / step, and the broker minimum stop     |
//|  distance (stops level and freeze level). Pure functions: pass   |
//|  the SymbolInfo values in, no terminal calls, testable.          |
//|  Rule: the volume is always rounded DOWN, never up to the        |
//|  minimum, so the money at risk is never above the request.       |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_RISK_SIZING_MQH
#define MQL_SIMPLIFY_RISK_SIZING_MQH

//+------------------------------------------------------------------+
//|  Decimal digits of a volume step (0.01 -> 2, 0.1 -> 1, 1 -> 0)    |
//+------------------------------------------------------------------+
int SimplifyStepDigits(const double step) {
  if(step <= 0)
    return 2;
  int d = 0;
  double s = step;
  while(d < 8 && MathAbs(s - MathRound(s)) > 1e-9) { s *= 10; d++; }
  return d;
}

//+------------------------------------------------------------------+
//|  Floors volume to the step, caps at vmax; 0 when below vmin or   |
//|  the inputs are invalid                                          |
//+------------------------------------------------------------------+
double SimplifyFloorVolume(const double volume, const double vmin, const double vmax,
                           const double step) {
  if(volume <= 0 || step <= 0 || vmin <= 0 || vmax < vmin)
    return 0;
  double v = MathFloor(volume / step + 1e-9) * step;
  if(v > vmax)
    v = MathFloor(vmax / step + 1e-9) * step;
  v = NormalizeDouble(v, SimplifyStepDigits(step));
  return (v < vmin - 1e-12) ? 0 : v;
}

//+------------------------------------------------------------------+
//|  Money lost by 1 lot over a price distance                       |
//|  (distance / tick size * tick value). 0 on invalid inputs.       |
//+------------------------------------------------------------------+
double SimplifyLossPerLot(const double distance, const double tickSize, const double tickValue) {
  if(distance <= 0 || tickSize <= 0 || tickValue <= 0)
    return 0;
  return distance / tickSize * tickValue;
}

//+------------------------------------------------------------------+
//|  Lot for a money risk over a stop distance, floored to the symbol |
//|  limits. 0 = cannot trade within the risk (skip the trade).      |
//+------------------------------------------------------------------+
double SimplifyLotForRisk(const double riskMoney, const double stopDistance,
                          const double tickSize, const double tickValue,
                          const double vmin, const double vmax, const double step) {
  double perLot = SimplifyLossPerLot(stopDistance, tickSize, tickValue);
  if(riskMoney <= 0 || perLot <= 0)
    return 0;
  return SimplifyFloorVolume(riskMoney / perLot, vmin, vmax, step);
}

//+------------------------------------------------------------------+
//|  Money at risk for a given volume and stop distance              |
//+------------------------------------------------------------------+
double SimplifyRiskForLot(const double volume, const double stopDistance,
                          const double tickSize, const double tickValue) {
  return volume * SimplifyLossPerLot(stopDistance, tickSize, tickValue);
}

//+------------------------------------------------------------------+
//|  Minimum distance between the market price and SL/TP accepted by |
//|  the broker: max(stops level, freeze level) + extra points,      |
//|  in price units                                                  |
//+------------------------------------------------------------------+
double SimplifyMinStopDistance(const long stopsLevelPoints, const long freezeLevelPoints,
                               const double point, const int extraPoints = 0) {
  long lv = MathMax(stopsLevelPoints, freezeLevelPoints);
  if(lv < 0) lv = 0;
  return (double)(lv + MathMax(extraPoints, 0)) * point;
}

//+------------------------------------------------------------------+
//|  Rounds a price to the tick size                                 |
//+------------------------------------------------------------------+
double SimplifyRoundToTick(const double price, const double tickSize) {
  if(tickSize <= 0)
    return price;
  return MathRound(price / tickSize) * tickSize;
}

//+------------------------------------------------------------------+
//|  Price distance in points -> money for a volume, from the symbol |
//|  point, tick size and tick value (e.g. WIN: point 1, tick 5,     |
//|  tick value 1.00 BRL -> 100 points = 20.00 BRL per contract).     |
//+------------------------------------------------------------------+
double SimplifyPointsToMoney(const double points, const double point, const double tickSize,
                             const double tickValue, const double volume) {
  if(point <= 0 || tickSize <= 0 || tickValue <= 0 || volume <= 0 || points < 0)
    return 0;
  return points * point / tickSize * tickValue * volume;
}

//+------------------------------------------------------------------+
//|  Money for a volume -> price distance in points (inverse)        |
//+------------------------------------------------------------------+
double SimplifyMoneyToPoints(const double money, const double point, const double tickSize,
                             const double tickValue, const double volume) {
  if(point <= 0 || tickSize <= 0 || tickValue <= 0 || volume <= 0 || money < 0)
    return 0;
  return money / (tickValue * volume) * tickSize / point;
}

#endif
