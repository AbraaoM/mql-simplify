//+------------------------------------------------------------------+
//|                                                    Positions.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"
#property version   "1.00"

#include "Operations.mqh"

class CPositions : public COperations {
 private:

 public:
  void CPositions :: ExpertPositions (long magicNumber,
                                      ulong &dest_tickets[]);

  void CPositions :: CloseAllPositions(string symbol, int deviation);

                     CPositions();
                    ~CPositions();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPositions::CPositions() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPositions::~CPositions() {
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
//|  Close all positions function                                    |
//+------------------------------------------------------------------+
void CPositions :: CloseAllPositions(string symbol, int deviation) {
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
