//+------------------------------------------------------------------+
//|                                                   CandleInfos.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"

class CCandleInfos {
 private:
  double             pastClose;

 public:

  CCandleInfos ::    CCandleInfos();

  double CCandleInfos :: CandleSize (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                     int u_shift = 1);

  bool CCandleInfos :: IsCandlePositive (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                         int u_shift = 1);

  bool CCandleInfos :: IsCandleNegative (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                         int u_shift = 1);

  bool CCandleInfos :: IsNewCandle(ENUM_TIMEFRAMES timeframe = 0);
};


//+------------------------------------------------------------------+
//|  Constructor                                                                |
//+------------------------------------------------------------------+
CCandleInfos :: CCandleInfos() {
  pastClose = 0;
}

//+------------------------------------------------------------------+
//|  Candle size function                                            |
//+------------------------------------------------------------------+
double CCandleInfos :: CandleSize (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                   int u_shift = 1) {
  return MathAbs(iOpen(_Symbol, u_timeframe, u_shift) - iClose(_Symbol, u_timeframe, u_shift));
}

//+------------------------------------------------------------------+
//| Is candle positive function                                      |
//+------------------------------------------------------------------+
bool CCandleInfos :: IsCandlePositive (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                       int u_shift = 1) {
  return iOpen(_Symbol, u_timeframe, u_shift) < iClose(_Symbol, u_timeframe, u_shift);
}

//+------------------------------------------------------------------+
//| Is candle negative function                                      |
//+------------------------------------------------------------------+
bool CCandleInfos :: IsCandleNegative (ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT,
                                       int u_shift = 1) {
  return iOpen(_Symbol, u_timeframe, u_shift) > iClose(_Symbol, u_timeframe, u_shift);
}

//+------------------------------------------------------------------+
//|  Is new candle function                                          |
//+------------------------------------------------------------------+
bool CCandleInfos :: IsNewCandle(ENUM_TIMEFRAMES timeframe = 0) {
  //--- compares the open time of the current bar (pastClose keeps that time):
  //    two bars with the same close price are still two candles
  double barTime = (double)iTime(NULL, timeframe, 0);
  if(barTime == 0)
    return false;
  if(pastClose != barTime) {
    pastClose = barTime;
    return true;
  }
  return false;
}
//+------------------------------------------------------------------+
