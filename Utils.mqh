//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>
#include "NewTypes.mqh"

class CUtils {
 private:
  double             pastClose;

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
  //|  Acumulated profit function                                     |
  //+------------------------------------------------------------------+
  double CUtils ::   AccumulatedProfit(datetime initDate_AP,
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
  //|  Close all positions function                                    |
  //+------------------------------------------------------------------+
  void CUtils ::     CloseAllPositions(string symbol, int deviation) {
    CTrade trade_TL;
    ulong ticket = 0;
    if(PositionSelect(symbol)) {
      for(int i = 0; i < PositionsTotal(); i++) {
        ticket = PositionGetTicket(i);
        trade_TL.PositionClose(ticket, deviation);
      }
    }
  }

  //+------------------------------------------------------------------+
  //|  Delete all orders function                                      |
  //+------------------------------------------------------------------+
  void CUtils ::     DeleteAllOrders() {
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
  //|  Number of trades in a period function                           |
  //+------------------------------------------------------------------+
  int CUtils :: NumberOfTrades (datetime initDate,
                                datetime finishDate) {
    HistorySelect(initDate, finishDate);
    return HistoryDealsTotal();
  }

  //+------------------------------------------------------------------+
  //|  Past ticket function                                            |
  //+------------------------------------------------------------------+
  ulong CUtils ::    PastOperationTicket(int shift) {
    uint dealsTotal;
    string today;

    today = TimeToString(TimeLocal(), TIME_DATE);

    HistorySelect(StringToTime(today), TimeCurrent());
    dealsTotal = HistoryDealsTotal();
    return HistoryDealGetTicket(dealsTotal - shift);
  }

  //+------------------------------------------------------------------+
  //|  Get deal type function                                          |
  //+------------------------------------------------------------------+
  TRADE_TYPE CUtils :: HistoryDealType(int shift) {
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
  double CUtils ::   HistoryDealPrice(int shift) {
    ulong ticket;

    ticket = PastOperationTicket(shift);

    return HistoryDealGetDouble(ticket, DEAL_PRICE);
  }

  //+------------------------------------------------------------------+
  //|  Detects a position closed by TP                                 |
  //+------------------------------------------------------------------+
  bool CUtils ::     TPDetector() {
    ulong ticket = PastOperationTicket(1);
    if(HistoryDealGetInteger(ticket, DEAL_REASON) == DEAL_REASON_TP)
      return true;
    return false;
  }

  //+------------------------------------------------------------------+
  //|  Time tokenizer function                                         |
  //+------------------------------------------------------------------+
  void CUtils :: TimeStringTokenizer (string time,
                                      string &tokenizedTime[]) {
    StringSplit(time, ':', tokenizedTime);
  }

  //+------------------------------------------------------------------+
  //|  String to timestamp function                                    |
  //+------------------------------------------------------------------+
  int CUtils :: StringTimeToInt (string time,
                                 ENUM_TIME_STRING_TO_INT_TYPES selector) {
    string tokenizedTime[];
    int absoluteValueTime = 0;

    TimeStringTokenizer(time, tokenizedTime);

    switch (selector) {
    case   HHMMSS:
      absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
      absoluteValueTime += (int)(StringToInteger(tokenizedTime[1]) * 60);
      absoluteValueTime += (int)StringToInteger(tokenizedTime[2]);
      break;
    case     HHMM:
      absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
      absoluteValueTime += (int)(StringToInteger(tokenizedTime[1]) * 60);
      break;
    case    MMSS:
      absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 60);
      absoluteValueTime += (int)StringToInteger(tokenizedTime[1]);
      break;
    case    HH:
      absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
      break;
    case     MM:
      absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 60);
      break;
    case   SS:
      absoluteValueTime = (int)StringToInteger(tokenizedTime[0]);
      break;
    }
    return absoluteValueTime;
  }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  Expert positions function                                       |
//+------------------------------------------------------------------+
void CUtils :: ExpertPositions (long magicNumber,
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
