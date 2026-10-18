//+------------------------------------------------------------------+
//|                                                  TestHistory.mq5 |
//|  Runtime tests (script, no account needed) for DealMath,         |
//|  DayClock, HistoryReader and HistoryMetrics. Writes              |
//|  MQL5\\Files\\mqlsimplify_history_results.txt, last line           |
//|  "RESULT PASS: n passed, 0 failed" or "RESULT FAIL: ...".        |
//+------------------------------------------------------------------+

#include "../DealMath.mqh"
#include "../DayClock.mqh"
#include "../HistoryReader.mqh"
#include "../HistoryMetrics.mqh"

int passed = 0, failed = 0, fileHandle = INVALID_HANDLE;

void Out(string s) {
  Print(s);
  if(fileHandle != INVALID_HANDLE)
    FileWriteString(fileHandle, s + "\r\n");
}
void Check(string name, bool ok, string detail = "") {
  if(ok) passed++;
  else { failed++; Out("FAIL " + name + " " + detail); }
}
void Near(string name, double got, double expected) {
  Check(name, MathAbs(got - expected) < 1e-9, "got " + DoubleToString(got, 8) + " expected " + DoubleToString(expected, 8));
}

class CCountListener : public CDealListener {
 public:
  int                deals;
                     CCountListener() : deals(0) {}
  virtual void       OnDeal(ulong ticket) { deals++; }
};

void TestDealMath() {
  Check("kind_buy", SimplifyDealKind(DEAL_TYPE_BUY) == SIMPLIFY_DEAL_TRADE);
  Check("kind_sell", SimplifyDealKind(DEAL_TYPE_SELL) == SIMPLIFY_DEAL_TRADE);
  Check("kind_balance", SimplifyDealKind(DEAL_TYPE_BALANCE) == SIMPLIFY_DEAL_BALANCE);
  Check("kind_credit", SimplifyDealKind(DEAL_TYPE_CREDIT) == SIMPLIFY_DEAL_OTHER_OP);
  Check("kind_bonus", SimplifyDealKind(DEAL_TYPE_BONUS) == SIMPLIFY_DEAL_OTHER_OP);
  Check("kind_correction", SimplifyDealKind(DEAL_TYPE_CORRECTION) == SIMPLIFY_DEAL_OTHER_OP);
  Check("kind_charge", SimplifyDealKind(DEAL_TYPE_CHARGE) == SIMPLIFY_DEAL_OTHER_OP);
  Check("kind_commission", SimplifyDealKind(DEAL_TYPE_COMMISSION) == SIMPLIFY_DEAL_COST);
  Check("kind_interest", SimplifyDealKind(DEAL_TYPE_INTEREST) == SIMPLIFY_DEAL_COST);
  Near("deal_result_trade", SimplifyDealResult(DEAL_TYPE_BUY, 10, -1, -0.5, -0.25), 8.25);
  Near("deal_result_balance", SimplifyDealResult(DEAL_TYPE_BALANCE, 1000, 0, 0, 0), 0);
  Near("history_profit_no_account", SimplifyHistoryProfit(0, TimeTradeServer()), 0);
  Near("floating_no_positions", SimplifyFloatingProfit(), 0);
}

void TestDayClock() {
  CDayClock c;
  datetime t = D'2026.10.18 05:00';
  Check("day_midnight", c.DayStart(t) == D'2026.10.18 00:00');
  Check("day_exact_boundary", c.DayStart(D'2026.10.18 00:00') == D'2026.10.18 00:00');
  c.SetHour(22);
  Check("day_22_before", c.DayStart(t) == D'2026.10.17 22:00');
  Check("day_22_after", c.DayStart(D'2026.10.18 23:00') == D'2026.10.18 22:00');
  Check("day_22_boundary_hour", c.BoundaryHour(t) == 22);
  c.SetHour(24);
  Check("day_invalid_hour", c.Hour() == 0);
  Check("day_today", c.Today() == c.DayStart(TimeTradeServer()));
}

void TestStats() {
  CTradeStats s;
  Check("stats_empty_pf", s.ProfitFactor() == 0 && !s.HasProfitFactor());
  Check("stats_empty_exp", s.Expectancy() == 0 && s.WinRate() == 0 && s.AverageWin() == 0 && s.AverageLoss() == 0);
  double r[] = {10, -5, -5, 20, -3, 0};
  for(int i = 0; i < ArraySize(r); i++)
    s.AddTradeResult(r[i], i >= 4);
  Check("stats_trades", s.trades == 6 && s.wins == 2 && s.losses == 3 && s.todayTrades == 2);
  Near("stats_gross_profit", s.grossProfit, 30);
  Near("stats_gross_loss", s.grossLoss, 13);
  Near("stats_pf", s.ProfitFactor(), 30.0 / 13.0);
  Near("stats_expectancy", s.Expectancy(), 17.0 / 6.0);
  Near("stats_winrate", s.WinRate(), 100.0 * 2 / 6);
  Near("stats_avg_win", s.AverageWin(), 15);
  Near("stats_avg_loss", s.AverageLoss(), 13.0 / 3.0);
  Near("stats_max_dd", s.maxDD, 10);
  Check("stats_loss_streak", s.maxLossStreak == 2 && s.lossStreak == 1);
  s.AddFlow(10, -1, -2, true);
  s.AddFlow(5, 0, -1, false);
  Near("stats_net", s.net, 11);
  Near("stats_today_net", s.todayNet, 7);
  Near("stats_commission", s.commission, -3);
  Near("stats_swap", s.swap, -1);
  s.AddOpen(4.5);
  s.AddOpen(-1.5);
  Check("stats_open", s.openPositions == 2 && MathAbs(s.floating - 3.0) < 1e-9);
  s.ResetDay();
  s.ResetOpen();
  Check("stats_resets", s.todayNet == 0 && s.todayTrades == 0 && s.floating == 0 && s.openPositions == 0 && s.trades == 6);
  CTradeStats w;
  w.AddTradeResult(5, false);
  Check("stats_no_loss", !w.HasProfitFactor() && w.ProfitFactor() == 0);
}

void TestDrawdown() {
  CDrawdown d;
  d.Add(10); d.Add(-4); d.Add(-3); d.Add(12); d.Add(-2);
  Near("dd_curve_value", d.Value(), 13);
  Near("dd_curve_peak", d.Peak(), 15);
  Near("dd_curve_max", d.MaxDrawdown(), 7);
  Near("dd_curve_now", d.Drawdown(), 2);
  CDrawdown e;
  e.Set(10000); e.Set(10250); e.Set(9900); e.Set(10100);
  Near("dd_level_peak", e.Peak(), 10250);
  Near("dd_level_max", e.MaxDrawdown(), 350);
}

void TestCosts() {
  CPositionCosts c;
  c.AddEntry(7, 1.0, -3.0);
  Near("cost_partial_1", c.TakeExitShare(7, 0.4, false), -1.2);
  Near("cost_partial_left", c.PendingCost(7), -1.8);
  Near("cost_partial_2", c.TakeExitShare(7, 0.6, false), -1.8);
  Near("cost_closed_volume", c.OpenVolume(7), 0);
  c.AddEntry(8, 1.0, -2.0);
  Near("cost_reversal_share", c.TakeExitShare(8, 1.5, true), -2.0);
  Near("cost_reversal_open", c.OpenVolume(8), 0.5);
  c.AddEntry(9, 0, -1.0);
  Near("cost_no_volume", c.TakeExitShare(9, 1.0, false), -1.0);
  Near("cost_unknown", c.TakeExitShare(10, 1.0, false), 0);
  Check("cost_count", c.Count() == 4);
  c.Reset();
  Check("cost_reset", c.Count() == 0 && c.PendingCost(7) == 0);
}

void TestReader() {
  CHistoryReader r;
  CCountListener l;
  r.Configure(10, 1);
  int n = r.Read(GetPointer(l));
  Check("reader_no_account", n == 0 && l.deals == 0 && r.TotalDeals() == 0 && !r.IsLoading(), "n=" + IntegerToString(n));
  Check("reader_null_listener", r.Read(NULL) == 0);
  r.Reset();
  Check("reader_reset", r.CursorTime() == 0 && r.IsLoading() && r.LastNewDeals() == 0);
}

void OnStart() {
  fileHandle = FileOpen("mqlsimplify_history_results.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
  TestDealMath();
  TestDayClock();
  TestStats();
  TestDrawdown();
  TestCosts();
  TestReader();
  Out(StringFormat("RESULT %s: %d passed, %d failed", failed == 0 ? "PASS" : "FAIL", passed, failed));
  if(fileHandle != INVALID_HANDLE)
    FileClose(fileHandle);
}
