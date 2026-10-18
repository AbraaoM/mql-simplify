//+------------------------------------------------------------------+
//|                                                   Operations.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>

#include "NewTypes.mqh"

//+------------------------------------------------------------------+
//|  Trading result of one deal: profit + commission + swap + fee.    |
//|  Only buy/sell deals count; balance, credit, bonus, charge,       |
//|  correction and the other non-trade deal types return 0, so       |
//|  deposits and withdrawals are never counted as profit.            |
//+------------------------------------------------------------------+
double SimplifyDealResult(ENUM_DEAL_TYPE type,
                          double profit,
                          double commission,
                          double swap,
                          double fee) {
  if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
    return 0;
  return profit + commission + swap + fee;
}

//+------------------------------------------------------------------+
//|  True for deals that are trades (buy/sell), false for balance,    |
//|  credit and the other non-trade deal types                        |
//+------------------------------------------------------------------+
bool SimplifyIsTradeDeal(ENUM_DEAL_TYPE type) {
  return type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL;
}

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
  double profitAcum = 0;

  HistorySelect(initDate_AP, finishDate_AP);
  int total = HistoryDealsTotal();
  for(int i = 0; i < total; i++) {
    ulong ticket = HistoryDealGetTicket(i);
    if(ticket == 0)
      continue;
    profitAcum += SimplifyDealResult((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE),
                                     HistoryDealGetDouble(ticket, DEAL_PROFIT),
                                     HistoryDealGetDouble(ticket, DEAL_COMMISSION),
                                     HistoryDealGetDouble(ticket, DEAL_SWAP),
                                     HistoryDealGetDouble(ticket, DEAL_FEE));
  }
  //--- floating result (profit + swap) of every open position on the symbol (hedging-safe)
  string symbol = (symbol_AP == NULL || symbol_AP == "") ? _Symbol : symbol_AP;
  for(int p = PositionsTotal() - 1; p >= 0; p--) {
    ulong pticket = PositionGetTicket(p);
    if(pticket == 0 || PositionGetString(POSITION_SYMBOL) != symbol)
      continue;
    profitAcum += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
  }

  return profitAcum;
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

  today = TimeToString(TimeLocal(), TIME_DATE);

  HistorySelect(StringToTime(today), TimeCurrent());
  dealsTotal = HistoryDealsTotal();
  return HistoryDealGetTicket(dealsTotal - shift);
}

//+------------------------------------------------------------------+
