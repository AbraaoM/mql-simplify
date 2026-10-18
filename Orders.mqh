//+------------------------------------------------------------------+
//|                                                       Orders.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"
#property version   "1.00"

#include "Operations.mqh"

class COrders : public COperations {
 private:
   
 public:
  void COrders ::    DeleteAllOrders();

                     COrders();
                    ~COrders();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrders::COrders() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrders::~COrders() {
}

//+------------------------------------------------------------------+
//|  Delete all orders function                                      |
//+------------------------------------------------------------------+
void COrders :: DeleteAllOrders() {
  ulong ticket = 0;
  //--- backwards: deleting an order shifts the indexes of the ones after it
  for(int i = OrdersTotal() - 1; i >= 0; i--) {
    ticket = OrderGetTicket(i);
    if(ticket != 0)
      tradeOperations.OrderDelete(ticket);
  }
}
//+------------------------------------------------------------------+
