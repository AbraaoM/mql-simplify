//+------------------------------------------------------------------+
//|                                                        Deals.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"
#property version   "1.00"

#include "Operations.mqh"

class CDeals : public COperations {
 private:

 public:
  TRADE_TYPE CDeals :: HistoryDealType(int shift);
  double CDeals ::   HistoryDealPrice(int shift);

                     CDeals();
                    ~CDeals();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::CDeals() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::~CDeals() {
}

//+------------------------------------------------------------------+
//|  Get deal type function                                          |
//+------------------------------------------------------------------+
TRADE_TYPE CDeals :: HistoryDealType(int shift) {
  ulong ticket;

  ticket = PastOperationTicket(shift);
  if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
    return BUY;
  if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
    return SELL;
  return NOTHING;
}

//+------------------------------------------------------------------+
//|  Get deal price function                                         |
//+------------------------------------------------------------------+
double CDeals :: HistoryDealPrice(int shift) {
  ulong ticket;

  ticket = PastOperationTicket(shift);

  return HistoryDealGetDouble(ticket, DEAL_PRICE);
}
//+------------------------------------------------------------------+
