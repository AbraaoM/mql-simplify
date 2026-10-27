//+------------------------------------------------------------------+
//|                                              TestB3Futures.mq5   |
//|  Runtime tests (script, no account needed) for B3Futures.mqh,    |
//|  PositionMode.mqh and RiskSizing points<->money. Writes          |
//|  MQL5\\Files\\mqlsimplify_b3_results.txt.                         |
//+------------------------------------------------------------------+
#include "../B3Futures.mqh"
#include "../PositionMode.mqh"
#include "../RiskSizing.mqh"

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
void Near(string name, double got, double want, double tol = 1e-9) {
  Check(name, MathAbs(got - want) <= tol, StringFormat("got=%.10g want=%.10g", got, want));
}
void Date(string name, datetime got, datetime want) {
  Check(name, got == want, TimeToString(got) + " want " + TimeToString(want));
}

void OnStart() {
  fileHandle = FileOpen("mqlsimplify_b3_results.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);

  //--- month codes
  Check("month_F", SimplifyFuturesMonth('F') == 1);
  Check("month_J", SimplifyFuturesMonth('J') == 4);
  Check("month_Z", SimplifyFuturesMonth('Z') == 12);
  Check("month_bad", SimplifyFuturesMonth('A') == 0);
  Check("date_bad", SimplifyMakeDate(2026, 13, 1) == 0);

  //--- Wednesday closest to the 15th, every weekday of the 15th
  Date("exp_wed15_2025_10", SimplifyB3IndexExpiry(2025, 10), D'2025.10.15');
  Date("exp_thu15_2026_10", SimplifyB3IndexExpiry(2026, 10), D'2026.10.14');
  Date("exp_sat15_2026_08", SimplifyB3IndexExpiry(2026, 8), D'2026.08.12');
  Date("exp_sun15_2026_02", SimplifyB3IndexExpiry(2026, 2), D'2026.02.18');
  Date("exp_mon15_2025_12", SimplifyB3IndexExpiry(2025, 12), D'2025.12.17');
  Date("exp_tue15_2026_12", SimplifyB3IndexExpiry(2026, 12), D'2026.12.16');
  Date("exp_mon15_2026_06", SimplifyB3IndexExpiry(2026, 6), D'2026.06.17');

  //--- symbol parsing
  Date("sym_WINZ26", SimplifyB3ExpiryFromSymbol("WINZ26", "WIN"), D'2026.12.16');
  Date("sym_INDQ26", SimplifyB3ExpiryFromSymbol("INDQ26", "IND"), D'2026.08.12');
  Date("sym_suffix", SimplifyB3ExpiryFromSymbol("WINZ26.fut", "WIN"), D'2026.12.16');
  Check("sym_continuous", SimplifyB3ExpiryFromSymbol("WIN$", "WIN") == 0);
  Check("sym_continuousN", SimplifyB3ExpiryFromSymbol("WIN$N", "WIN") == 0);
  Check("sym_other_root", SimplifyB3ExpiryFromSymbol("WDOZ26", "WIN") == 0);
  Check("sym_bad_month", SimplifyB3ExpiryFromSymbol("WINA26", "WIN") == 0);

  //--- days to expiry and the roll rule
  datetime exp = D'2026.12.16';
  Check("days_7", SimplifyDaysToExpiry(D'2026.12.09 10:30', exp) == 7);
  Check("days_0", SimplifyDaysToExpiry(D'2026.12.16 17:59', exp) == 0);
  Check("days_neg", SimplifyDaysToExpiry(D'2026.12.17 09:00', exp) == -1);
  Check("days_unknown", SimplifyDaysToExpiry(D'2026.12.09', 0) == INT_MAX);
  Check("roll_far_ok", !SimplifyRollBlocksEntry(7, 5));
  Check("roll_edge_blocks", SimplifyRollBlocksEntry(5, 5));
  Check("roll_expiry_day", SimplifyRollBlocksEntry(0, 5));
  Check("roll_expired", SimplifyRollBlocksEntry(-1, 5));
  Check("roll_zero_days_only_expiry", SimplifyRollBlocksEntry(0, 0) && !SimplifyRollBlocksEntry(1, 0));
  Check("roll_unknown_free", !SimplifyRollBlocksEntry(INT_MAX, 5));

  //--- netting / hedging
  Check("mode_hedging", !SimplifyIsNetting(ACCOUNT_MARGIN_MODE_RETAIL_HEDGING));
  Check("mode_netting", SimplifyIsNetting(ACCOUNT_MARGIN_MODE_RETAIL_NETTING));
  Check("mode_exchange", SimplifyIsNetting(ACCOUNT_MARGIN_MODE_EXCHANGE));
  Check("net_empty_ok", SimplifyCanOpenEntry(true, 0, 0, 1));
  Check("net_own_blocks", !SimplifyCanOpenEntry(true, 1, 1, 3));
  Check("net_foreign_blocks", !SimplifyCanOpenEntry(true, 1, 0, 3));
  Check("hedge_foreign_ok", SimplifyCanOpenEntry(false, 2, 0, 1));
  Check("hedge_limit", !SimplifyCanOpenEntry(false, 2, 1, 1));
  Check("hedge_below_limit", SimplifyCanOpenEntry(false, 2, 1, 2));
  Check("bad_max", !SimplifyCanOpenEntry(false, 0, 0, 0));
  ENUM_ORDER_TYPE ot; double v = 0;
  Check("close_buy", SimplifyCloseOrder(POSITION_TYPE_BUY, 3, ot, v) && ot == ORDER_TYPE_SELL && v == 3);
  Check("close_sell", SimplifyCloseOrder(POSITION_TYPE_SELL, 2, ot, v) && ot == ORDER_TYPE_BUY && v == 2);
  Check("close_zero", !SimplifyCloseOrder(POSITION_TYPE_BUY, 0, ot, v));

  //--- points <-> money: WIN point 1, tick 5, tick value 1.00 BRL (0.20 BRL/point)
  Near("win_100pts_1c", SimplifyPointsToMoney(100, 1, 5, 1.0, 1), 20.0);
  Near("win_250pts_3c", SimplifyPointsToMoney(250, 1, 5, 1.0, 3), 150.0);
  Near("win_money_back", SimplifyMoneyToPoints(150, 1, 5, 1.0, 3), 250.0);
  Near("eurusd_pts", SimplifyPointsToMoney(100, 0.00001, 0.00001, 1.0, 0.1), 10.0);
  Near("bad_inputs", SimplifyPointsToMoney(100, 0, 5, 1, 1), 0.0);
  //--- whole contracts: 200 BRL at risk, 300-point stop (60 BRL/contract) -> 3
  Near("win_lot_3", SimplifyLotForRisk(200, 300, 5, 1.0, 1, 10, 1), 3.0);
  Near("win_lot_floor0", SimplifyLotForRisk(50, 300, 5, 1.0, 1, 10, 1), 0.0);
  Near("win_lot_cap", SimplifyLotForRisk(5000, 300, 5, 1.0, 1, 2, 1), 2.0);

  Out(StringFormat("RESULT %s %d/%d", failed == 0 ? "PASS" : "FAIL", passed, passed + failed));
  if(fileHandle != INVALID_HANDLE) FileClose(fileHandle);
}
