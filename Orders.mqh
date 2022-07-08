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
  if(OrdersTotal() != 0) {
    for(int i = 0; i < OrdersTotal(); i++) {
      ticket = OrderGetTicket(i);
      tradeOperations.OrderDelete(ticket);
    }
  }
}
//+------------------------------------------------------------------+
