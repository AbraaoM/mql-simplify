//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>
#include "NewTypes.mqh"
#include "Operations.mqh"

class CUtils {
 private:
  double             pastClose;
  COperations        operations;

 public:
  double CUtils ::   CandleSize(ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT, int u_shift = 1);
  bool CUtils ::     IsCandlePositive(ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT, int u_shift = 1);
  bool CUtils ::     IsCandleNegative(ENUM_TIMEFRAMES u_timeframe = PERIOD_CURRENT, int u_shift = 1);
  void CUtils ::     ExpertPositions(long magicNumber, ulong &tickets[]);
  void CUtils ::     ArrayShift(int ut_shift, double &ut_buffer[]);
  bool CUtils ::     BooleanArray(bool& ut_array[]);

  CUtils ::          CUtils() {
    pastClose = 0;
  }

  //+------------------------------------------------------------------+
  //|  Detects a position closed by TP                                 |
  //+------------------------------------------------------------------+
  bool CUtils ::     TPDetector() {
    ulong ticket = operations.PastOperationTicket(1);
    if(HistoryDealGetInteger(ticket, DEAL_REASON) == DEAL_REASON_TP)
      return true;
    return false;
  }
};

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CUtils :: ArrayShift(int ut_shift,
                          double &ut_buffer[]) {
  if(ut_shift != 0) {
    ArraySetAsSeries(ut_buffer, true);
    for(int i = ut_shift; i < ArraySize(ut_buffer); i++)
      ut_buffer[i - ut_shift] = ut_buffer[i];
  }
}

//+------------------------------------------------------------------+
//|  Booolean Array verification function                            |
//+------------------------------------------------------------------+
bool CUtils :: BooleanArray(bool& ut_array[]) {
  for(int i = 0; i < ArrayRange(ut_array, 0); i++)
    if(ut_array[i] == false)
      return false;
  return true;
}
//+------------------------------------------------------------------+