//+------------------------------------------------------------------+
//|                                               HistoryMetrics.mqh |
//|  Trade statistics from the deal history, safe with 0 trades:     |
//|  - SimplifyDealKind(): trade, balance, other balance operation   |
//|    or separate cost deal;                                        |
//|  - CTradeStats: trades, wins, losses, gross profit/loss, net,    |
//|    profit factor, expectancy, win rate, max drawdown of the      |
//|    closed-trade curve, loss streak, today and open results;      |
//|  - CDrawdown: peak and max drawdown of any running curve;        |
//|  - CPositionCosts: one result per exit deal, with its share of   |
//|    the entry costs (commission, fee, swap) of the position.      |
//|  No trade code.                                                  |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_HISTORY_METRICS_MQH
#define MQL_SIMPLIFY_HISTORY_METRICS_MQH

#include <Generic\HashMap.mqh>
#include "DealMath.mqh"

enum ENUM_SIMPLIFY_DEAL_KIND {
  SIMPLIFY_DEAL_TRADE,      // buy / sell
  SIMPLIFY_DEAL_BALANCE,    // deposit / withdrawal
  SIMPLIFY_DEAL_OTHER_OP,   // credit, bonus, correction, charge
  SIMPLIFY_DEAL_COST        // separate commission, interest, dividend, tax deals
};

//+------------------------------------------------------------------+
//|  Kind of a deal type                                             |
//+------------------------------------------------------------------+
ENUM_SIMPLIFY_DEAL_KIND SimplifyDealKind(ENUM_DEAL_TYPE type) {
  if(SimplifyIsTradeDeal(type))
    return SIMPLIFY_DEAL_TRADE;
  if(type == DEAL_TYPE_BALANCE)
    return SIMPLIFY_DEAL_BALANCE;
  if(type == DEAL_TYPE_CREDIT || type == DEAL_TYPE_BONUS || type == DEAL_TYPE_CORRECTION || type == DEAL_TYPE_CHARGE)
    return SIMPLIFY_DEAL_OTHER_OP;
  return SIMPLIFY_DEAL_COST;
}

//+------------------------------------------------------------------+
//|  Peak and max drawdown of a running curve (money)                |
//+------------------------------------------------------------------+
class CDrawdown {
 private:
  double             value;
  double             peak;
  double             maxDD;
  bool               started;

 public:
                     CDrawdown() { Reset(); }
  void               Reset() { value = 0; peak = 0; maxDD = 0; started = false; }
  //--- curve starts at 0 and moves by delta (closed results)
  void               Add(double delta) { Set(value + delta); started = true; }
  //--- curve jumps to a level (for example the equity); the first level is the first peak
  void               Set(double level);
  double             Value() const { return value; }
  double             Peak() const { return peak; }
  double             MaxDrawdown() const { return maxDD; }
  double             Drawdown() const { return peak - value; }
};

void CDrawdown :: Set(double level) {
  value = level;
  if(level > peak)
    peak = level;
  if(peak - level > maxDD)
    maxDD = peak - level;
}

//+------------------------------------------------------------------+
//|  Trade statistics                                                |
//+------------------------------------------------------------------+
class CTradeStats {
 public:
  string             key;             // name of the group (free text)
  int                trades;          // closed trade results (exit deals)
  int                wins;
  int                losses;
  double             grossProfit;     // sum of positive results
  double             grossLoss;       // sum of negative results (positive number)
  double             net;             // trading cash flows: profit + swap + commission + fee
  double             commission;      // commission + fee (signed, normally negative)
  double             swap;
  double             curve;           // closed-trade curve
  double             curvePeak;
  double             maxDD;           // max drawdown of the closed-trade curve (money)
  int                lossStreak;
  int                maxLossStreak;
  double             todayNet;        // trading cash flows since the day start
  int                todayTrades;
  double             floating;        // open P/L + swap of open positions
  int                openPositions;

                     CTradeStats() { Reset(""); }
  void               Reset(string newKey);
  void               ResetDay() { todayNet = 0; todayTrades = 0; }
  void               ResetOpen() { floating = 0; openPositions = 0; }
  //--- one trade deal: its cash flows
  void               AddFlow(double profit, double swapValue, double commissionValue, bool today);
  //--- one closed result (exit deal + its share of entry costs)
  void               AddTradeResult(double result, bool today);
  void               AddOpen(double floatingValue) { floating += floatingValue; openPositions++; }
  //--- metrics (0 when there is nothing to measure)
  bool               HasProfitFactor() const { return grossLoss > 0.0; }
  double             ProfitFactor() const { return grossLoss > 0.0 ? grossProfit / grossLoss : 0.0; }
  double             Expectancy() const { return trades > 0 ? (grossProfit - grossLoss) / trades : 0.0; }
  double             WinRate() const { return trades > 0 ? 100.0 * wins / trades : 0.0; }
  double             AverageWin() const { return wins > 0 ? grossProfit / wins : 0.0; }
  double             AverageLoss() const { return losses > 0 ? grossLoss / losses : 0.0; }
};

void CTradeStats :: Reset(string newKey) {
  key = newKey;
  trades = 0; wins = 0; losses = 0;
  grossProfit = 0; grossLoss = 0; net = 0; commission = 0; swap = 0;
  curve = 0; curvePeak = 0; maxDD = 0; lossStreak = 0; maxLossStreak = 0;
  todayNet = 0; todayTrades = 0; floating = 0; openPositions = 0;
}

void CTradeStats :: AddFlow(double profit, double swapValue, double commissionValue, bool today) {
  double v = profit + swapValue + commissionValue;
  net += v;
  swap += swapValue;
  commission += commissionValue;
  if(today)
    todayNet += v;
}

void CTradeStats :: AddTradeResult(double result, bool today) {
  trades++;
  if(today)
    todayTrades++;
  if(result > 0.0) {
    wins++;
    grossProfit += result;
    lossStreak = 0;
  } else if(result < 0.0) {
    losses++;
    grossLoss += -result;
    lossStreak++;
    if(lossStreak > maxLossStreak)
      maxLossStreak = lossStreak;
  }
  curve += result;
  if(curve > curvePeak)
    curvePeak = curve;
  if(curvePeak - curve > maxDD)
    maxDD = curvePeak - curve;
}

//+------------------------------------------------------------------+
//|  Entry costs per position, shared among its exit deals by volume |
//+------------------------------------------------------------------+
class CPositionCosts {
 private:
  CHashMap<ulong, int> index;
  double             pendingCost[];
  double             openVolume[];

  int                Slot(ulong positionId);

 public:
  void               Reset();
  //--- entry deal: remember its costs (swap + commission + fee) and volume
  void               AddEntry(ulong positionId, double volume, double cost);
  //--- exit deal (OUT, INOUT, OUT_BY): returns the share of the pending entry
  //--- costs for this volume; INOUT opens the remainder on the other side
  double             TakeExitShare(ulong positionId, double volume, bool reversal);
  double             PendingCost(ulong positionId);
  double             OpenVolume(ulong positionId);
  int                Count() const { return ArraySize(pendingCost); }
};

void CPositionCosts :: Reset() {
  index.Clear();
  ArrayFree(pendingCost);
  ArrayFree(openVolume);
}

int CPositionCosts :: Slot(ulong positionId) {
  int i;
  if(index.TryGetValue(positionId, i))
    return i;
  i = ArraySize(pendingCost);
  ArrayResize(pendingCost, i + 1, 256);
  ArrayResize(openVolume, i + 1, 256);
  pendingCost[i] = 0;
  openVolume[i] = 0;
  index.Add(positionId, i);
  return i;
}

void CPositionCosts :: AddEntry(ulong positionId, double volume, double cost) {
  int p = Slot(positionId);
  pendingCost[p] += cost;
  openVolume[p] += volume;
}

double CPositionCosts :: TakeExitShare(ulong positionId, double volume, bool reversal) {
  int p = Slot(positionId);
  double share = 0;
  double oldOpen = openVolume[p];
  if(oldOpen > 0.0) {
    double k = MathMin(1.0, volume / oldOpen);
    share = pendingCost[p] * k;
    pendingCost[p] -= share;
    openVolume[p] = MathMax(0.0, oldOpen - volume);
  } else {
    share = pendingCost[p];
    pendingCost[p] = 0;
  }
  if(reversal)
    openVolume[p] = MathMax(0.0, volume - oldOpen);
  return share;
}

double CPositionCosts :: PendingCost(ulong positionId) {
  int i;
  return index.TryGetValue(positionId, i) ? pendingCost[i] : 0.0;
}

double CPositionCosts :: OpenVolume(ulong positionId) {
  int i;
  return index.TryGetValue(positionId, i) ? openVolume[i] : 0.0;
}

#endif
