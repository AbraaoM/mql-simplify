//+------------------------------------------------------------------+
//|                                                   Operations.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"

class COperations {
  double COperations :: AccumulatedProfit(datetime initDate,
                                          datetime finishDate,
                                          string symbol_AP = NULL);

  int COperations :: NumberOfTrades (datetime initDate,
                                     datetime finishDate);

  ulong COperations :: PastOperationTicket(int shift);
};

class COrders {
  void COrders ::    DeleteAllOrders();
}

class CPositions {
  void CPositions :: ExpertPositions (long magicNumber,
                                      ulong &dest_tickets[]);
}

//+------------------------------------------------------------------+
//|  Acumulated profit function                                     |
//+------------------------------------------------------------------+
double COperations :: AccumulatedProfit(datetime initDate_AP,
                                        datetime finishDate_AP,
                                        string symbol_AP = NULL) {
  double profitAcum = 0;

  HistorySelect(initDate_AP, finishDate_AP);
  for(int i = 1; i <= HistoryDealsTotal(); i++) {
    ulong ticket = HistoryDealGetTicket(i);
    profitAcum += HistoryDealGetDouble(ticket, DEAL_PROFIT);
  }
  if(PositionSelect(symbol_AP == NULL ? _Symbol : symbol_AP)) {
    profitAcum += PositionGetDouble(POSITION_PROFIT);
  }

  return profitAcum;
}

//+------------------------------------------------------------------+
//|  Number of trades in a period function                           |
//+------------------------------------------------------------------+
int COperations :: NumberOfTrades (datetime initDate,
                                   datetime finishDate) {
  HistorySelect(initDate, finishDate);
  return HistoryDealsTotal();
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
//|  Delete all orders function                                      |
//+------------------------------------------------------------------+
void COrders :: DeleteAllOrders() {
  CTrade trade_DAO;
  ulong ticket = 0;
  if(OrdersTotal() != 0) {
    for(int i = 0; i < OrdersTotal(); i++) {
      ticket = OrderGetTicket(i);
      trade_DAO.OrderDelete(ticket);
    }
  }
}

//+------------------------------------------------------------------+
//|  Expert positions function                                       |
//+------------------------------------------------------------------+
void CPositions :: ExpertPositions (long magicNumber,
                                    ulong &dest_tickets[]) {
  ulong ticket;
  ArrayFree(dest_tickets);

  for(int i = 0; i < PositionsTotal(); i++) {
    ticket = PositionGetTicket(i);
    PositionSelectByTicket(ticket);
    if(PositionGetInteger(POSITION_MAGIC) == magicNumber)
      ArrayResize(dest_tickets, i + 1);
    dest_tickets[i] = ticket;
  }
}
//+------------------------------------------------------------------+