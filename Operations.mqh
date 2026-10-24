//+------------------------------------------------------------------+
//|                                                   Operations.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>

#include "NewTypes.mqh"
#include "DealMath.mqh"

class COperations {
 protected:
  CTrade             tradeOperations;

 public:
  double COperations :: AccumulatedProfit(datetime initDate,
                                          datetime finishDate,
                                          string symbol_AP = NULL);

  int COperations :: NumberOfTrades (datetime initDate,
                                     datetime finishDate);

  ulong COperations :: PastOperationTicket(int shift);
};

//+------------------------------------------------------------------+
//|  Acumulated profit function                                     |
//+------------------------------------------------------------------+
double COperations :: AccumulatedProfit(datetime initDate_AP,
                                        datetime finishDate_AP,
                                        string symbol_AP = NULL) {
  //--- closed deals of the period (any symbol) + floating result on the symbol (see DealMath.mqh)
  return SimplifyHistoryProfit(initDate_AP, finishDate_AP) + SimplifyFloatingProfit(symbol_AP);
}

//+------------------------------------------------------------------+
//|  Number of trades in a period function                           |
//+------------------------------------------------------------------+
int COperations :: NumberOfTrades (datetime initDate,
                                   datetime finishDate) {
  HistorySelect(initDate, finishDate);
  int total = HistoryDealsTotal(), trades = 0;
  for(int i = 0; i < total; i++) {
    ulong ticket = HistoryDealGetTicket(i);
    if(ticket != 0 && SimplifyIsTradeDeal((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE)))
      trades++;
  }
  return trades;
}

//+------------------------------------------------------------------+
//|  Past ticket function                                            |
//+------------------------------------------------------------------+
ulong COperations :: PastOperationTicket(int shift) {
  uint dealsTotal;
  string today;

  //--- "today" is the trade server's day, not the PC clock's
  today = TimeToString(TimeTradeServer(), TIME_DATE);

  HistorySelect(StringToTime(today), TimeTradeServer());
  dealsTotal = HistoryDealsTotal();
  //--- 0 (no deal) when shift is outside 1..dealsTotal (the uint index used to wrap around)
  if(shift < 1 || (uint)shift > dealsTotal)
    return 0;
  return HistoryDealGetTicket(dealsTotal - shift);
}

//+------------------------------------------------------------------+
