//+------------------------------------------------------------------+
//|                                             TradeFreeHeaders.mq5 |
//|  Build check: an indicator that includes every trade-free header |
//|  of the library. It must compile 0 errors / 0 warnings and must  |
//|  not pull Trade.mqh, CTrade, OrderSend or MessageBox.            |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_plots 0

#include "../NewTypes.mqh"
#include "../Graphic.mqh"
#include "../Storage.mqh"
#include "../TimeManipulation.mqh"
#include "../DealMath.mqh"

int OnInit() {
  return INIT_SUCCEEDED;
}

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  if(prev_calculated == 0) {
    CTimeManipulation tm;
    Comment(tm.IntTimeToString(3600), " ",
            SimplifyHistoryProfit(0, TimeTradeServer()) + SimplifyFloatingProfit(), " ",
            SimplifyIsTradeDeal(DEAL_TYPE_BALANCE));
  }
  return rates_total;
}
