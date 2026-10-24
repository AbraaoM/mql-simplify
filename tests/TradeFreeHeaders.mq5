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
#include "../DayClock.mqh"
#include "../HistoryReader.mqh"
#include "../HistoryMetrics.mqh"
#include "../DealGroups.mqh"

class CNoopListener : public CDealListener {
 public:
  int                deals;
                     CNoopListener() : deals(0) {}
  virtual void       OnDeal(ulong ticket) { deals++; }
};

CHistoryReader reader;
CNoopListener  noopListener;
CDayClock      dayClock;

int OnInit() {
  reader.Configure(500, 10);
  dayClock.SetHour(0);
  return INIT_SUCCEEDED;
}

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  if(prev_calculated == 0) {
    reader.Read(GetPointer(noopListener));
    CTradeStats stats;
    stats.AddTradeResult(SimplifyHistoryProfit(dayClock.Today(), TimeTradeServer()) + SimplifyFloatingProfit(), true);
    CDrawdown dd;
    dd.Set(AccountInfoDouble(ACCOUNT_EQUITY));
    CPositionCosts costs;
    costs.AddEntry(1, 1.0, 0.0);
    CDealGroups groups;
    groups.Configure(DEAL_GROUP_NAME, "1=A");
    groups.GroupOfPosition(1, 1, _Symbol);
    CTimeManipulation tm;
    Comment(tm.IntTimeToString(dayClock.BoundaryHour(TimeTradeServer()) * 3600), " ",
            (int)SimplifyDealKind(DEAL_TYPE_BALANCE), " ", stats.ProfitFactor(), " ", dd.MaxDrawdown(), " ",
            costs.TakeExitShare(1, 1.0, false));
  }
  return rates_total;
}
