//+------------------------------------------------------------------+
//|                                                     DealMath.mqh |
//|  Trade-free helpers for deal results. No CTrade, no OrderSend:   |
//|  safe to include in indicators and read-only tools.              |
//|  Operations.mqh includes this file, so COperations users get the |
//|  same functions as before.                                       |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_DEAL_MATH_MQH
#define MQL_SIMPLIFY_DEAL_MATH_MQH

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

//+------------------------------------------------------------------+
//|  Trading result of one history deal by ticket (history must be   |
//|  selected): profit + commission + swap + fee, 0 for non-trade    |
//|  deals                                                           |
//+------------------------------------------------------------------+
double SimplifyDealResult(ulong ticket) {
  return SimplifyDealResult((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE),
                            HistoryDealGetDouble(ticket, DEAL_PROFIT),
                            HistoryDealGetDouble(ticket, DEAL_COMMISSION),
                            HistoryDealGetDouble(ticket, DEAL_SWAP),
                            HistoryDealGetDouble(ticket, DEAL_FEE));
}

//+------------------------------------------------------------------+
//|  Sum of the trading results of the deals between two dates       |
//|  (all symbols). Selects the history of the period.               |
//+------------------------------------------------------------------+
double SimplifyHistoryProfit(datetime initDate,
                             datetime finishDate) {
  double profitAcum = 0;

  HistorySelect(initDate, finishDate);
  int total = HistoryDealsTotal();
  for(int i = 0; i < total; i++) {
    ulong ticket = HistoryDealGetTicket(i);
    if(ticket == 0)
      continue;
    profitAcum += SimplifyDealResult(ticket);
  }
  return profitAcum;
}

//+------------------------------------------------------------------+
//|  Floating result (profit + swap) of every open position on the   |
//|  symbol (NULL or "" = _Symbol). Hedging-safe.                    |
//+------------------------------------------------------------------+
double SimplifyFloatingProfit(string symbol_FP = NULL) {
  double floating = 0;
  string symbol = (symbol_FP == NULL || symbol_FP == "") ? _Symbol : symbol_FP;
  for(int p = PositionsTotal() - 1; p >= 0; p--) {
    ulong pticket = PositionGetTicket(p);
    if(pticket == 0 || PositionGetString(POSITION_SYMBOL) != symbol)
      continue;
    floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
  }
  return floating;
}

#endif
