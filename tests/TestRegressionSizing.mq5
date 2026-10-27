//+------------------------------------------------------------------+
//|                                          TestRegressionSizing.mq5 |
//|  Runtime tests (script, no account needed) for Regression.mqh    |
//|  and RiskSizing.mqh. Writes                                      |
//|  MQL5\\Files\\mqlsimplify_regression_results.txt.                 |
//+------------------------------------------------------------------+
#include "../Regression.mqh"
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

void OnStart() {
  fileHandle = FileOpen("mqlsimplify_regression_results.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
  SimplifyLinRegResult r;

  //--- perfect line y = 2 + 0.5x: slope, intercept, last, stdev 0, r2 1
  double line[10];
  for(int i = 0; i < 10; i++) line[i] = 2.0 + 0.5 * i;
  Check("line_ok", SimplifyLinReg(line, 0, 10, r));
  Near("line_slope", r.slope, 0.5);
  Near("line_intercept", r.intercept, 2.0);
  Near("line_last", r.last, 6.5);
  Near("line_stdev", r.stdev, 0.0);
  Near("line_r2", r.r2, 1.0);
  Near("line_upper_k2", SimplifyLinRegUpper(r, 2), 6.5);
  Near("line_score_flat_stdev", SimplifyLinRegTrendScore(r), 0.0);

  //--- sub-window: values[4..9] of the same line, x restarts at 0
  Check("sub_ok", SimplifyLinReg(line, 4, 6, r));
  Near("sub_intercept", r.intercept, 4.0);
  Near("sub_last", r.last, 6.5);
  Check("last_ok", SimplifyLinRegLast(line, 3, r));
  Near("last_window_intercept", r.intercept, 5.5);

  //--- known residuals: y = {1,3,2,4} -> slope 0.8, intercept 1.3
  //    fitted 1.3,2.1,2.9,3.7; residuals -0.3,0.9,-0.9,0.3; SSres = 1.8
  double y4[4] = {1, 3, 2, 4};
  Check("y4_ok", SimplifyLinReg(y4, 0, 4, r));
  Near("y4_slope", r.slope, 0.8);
  Near("y4_intercept", r.intercept, 1.3);
  Near("y4_last", r.last, 3.7);
  Near("y4_stdev", r.stdev, MathSqrt(1.8 / 4));
  Near("y4_r2", r.r2, 1 - 1.8 / 5.0);
  Near("y4_lower_k1", SimplifyLinRegLower(r, 1), 3.7 - MathSqrt(0.45));
  Near("y4_score", SimplifyLinRegTrendScore(r), 0.8 * 3 / MathSqrt(0.45));

  //--- flat series: slope 0, r2 0
  double flat[5] = {7, 7, 7, 7, 7};
  Check("flat_ok", SimplifyLinReg(flat, 0, 5, r));
  Near("flat_slope", r.slope, 0);
  Near("flat_r2", r.r2, 0);

  //--- invalid windows
  Check("count_1", !SimplifyLinReg(line, 0, 1, r));
  Check("out_of_range", !SimplifyLinReg(line, 5, 6, r));
  Check("negative_start", !SimplifyLinReg(line, -1, 3, r));
  Check("invalid_score", SimplifyLinRegTrendScore(r) == 0);

  //--- step digits
  Check("digits_001", SimplifyStepDigits(0.01) == 2);
  Check("digits_01", SimplifyStepDigits(0.1) == 1);
  Check("digits_1", SimplifyStepDigits(1.0) == 0);
  Check("digits_0001", SimplifyStepDigits(0.001) == 3);

  //--- floor volume: down to step, cap at max, 0 below min
  Near("floor_basic", SimplifyFloorVolume(0.237, 0.01, 100, 0.01), 0.23);
  Near("floor_exact", SimplifyFloorVolume(0.3, 0.01, 100, 0.01), 0.3);
  Near("floor_cap", SimplifyFloorVolume(250, 0.01, 100, 0.01), 100);
  Near("floor_below_min", SimplifyFloorVolume(0.009, 0.01, 100, 0.01), 0);
  Near("floor_step_01", SimplifyFloorVolume(0.79, 0.1, 50, 0.1), 0.7);
  Near("floor_min_not_on_step", SimplifyFloorVolume(0.15, 0.2, 10, 0.1), 0);
  Near("floor_bad_step", SimplifyFloorVolume(1, 0.01, 100, 0), 0);
  Near("floor_negative", SimplifyFloorVolume(-1, 0.01, 100, 0.01), 0);

  //--- loss per lot and lot for risk
  //    EURUSD-like: tick 0.00001 worth 1.0 per lot; 200-point stop = 0.002 -> 200 per lot
  Near("loss_per_lot", SimplifyLossPerLot(0.002, 0.00001, 1.0), 200, 1e-6);
  Near("lot_risk_100", SimplifyLotForRisk(100, 0.002, 0.00001, 1.0, 0.01, 100, 0.01), 0.5);
  Near("lot_risk_floor", SimplifyLotForRisk(99, 0.002, 0.00001, 1.0, 0.01, 100, 0.01), 0.49);
  Near("lot_risk_too_small", SimplifyLotForRisk(1, 0.002, 0.00001, 1.0, 0.01, 100, 0.01), 0);
  Near("lot_risk_zero_stop", SimplifyLotForRisk(100, 0, 0.00001, 1.0, 0.01, 100, 0.01), 0);
  //    XAUUSD-like: tick 0.01 worth 1.0 per lot; $5 stop -> 500 per lot; risk 50 -> 0.1
  Near("lot_gold", SimplifyLotForRisk(50, 5.0, 0.01, 1.0, 0.01, 50, 0.01), 0.1);
  //    risk of the floored lot never above the request
  double lot = SimplifyLotForRisk(73.3, 0.00137, 0.00001, 1.0, 0.01, 100, 0.01);
  Check("risk_not_above", SimplifyRiskForLot(lot, 0.00137, 0.00001, 1.0) <= 73.3 + 1e-9,
        DoubleToString(lot, 2));

  //--- broker minimum stop distance
  Near("min_stop_stops", SimplifyMinStopDistance(30, 10, 0.00001), 0.0003, 1e-12);
  Near("min_stop_freeze", SimplifyMinStopDistance(10, 40, 0.00001, 5), 0.00045, 1e-12);
  Near("min_stop_zero", SimplifyMinStopDistance(0, 0, 0.01), 0, 1e-12);
  Near("round_tick", SimplifyRoundToTick(1.234567, 0.00005), 1.23455, 1e-12);
  Near("round_tick_zero", SimplifyRoundToTick(1.5, 0), 1.5);

  Out(StringFormat("RESULT %s: %d passed, %d failed", failed == 0 ? "PASS" : "FAIL", passed, failed));
  if(fileHandle != INVALID_HANDLE) FileClose(fileHandle);
}
