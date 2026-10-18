# History: DayClock, HistoryReader, HistoryMetrics

Trade-free modules to read the deal history and measure results. None of them includes `Trade.mqh`, so they can be used by indicators and read-only panels.

## DayClock.mqh: CDayClock

Day boundaries in trade server time. The base clock starts the day at a fixed server hour; derive from `CDayClock` and override `DayStart()` when the boundary depends on the date (a reset at midnight of a time zone with daylight saving, for example).

- **void** SetHour(**int** hour) - 0 to 23 (other values = 0)
- **datetime** DayStart(**datetime** t) - start of the day that contains server time t (virtual)
- **int** BoundaryHour(**datetime** t) - server hour of that boundary (virtual)
- **datetime** Today() - start of the current server day

## HistoryReader.mqh: CHistoryReader, CDealListener

Incremental reader. Each `Read()` delivers only the deals that were not delivered before, oldest first, with a work cap per call, so a long history is loaded over several `OnTimer` calls without freezing the chart. The cursor is the time of the last delivered deal plus the tickets already delivered at that second.

```c++
class CMyListener : public CDealListener {
 public:
  virtual void OnDeal(ulong ticket) { /* HistoryDealGet*(ticket, ...) */ }
};
CHistoryReader reader;
CMyListener    listener;
void OnTimer() { reader.Read(GetPointer(listener)); }
```

- **void** Configure(**int** maxDealsPerCall, **int** maxMsPerCall) - defaults 2000 deals / 20 ms (minimum 100 / 5)
- **int** Read(**CDealListener\*** listener) - returns the number of new deals
- **void** Reset() - the next calls deliver the whole history again
- **bool** IsLoading() - true when the last call stopped at the cap
- CursorTime(), LastNewDeals(), TotalDeals(), LastReadMicroseconds(), MaxReadMicroseconds()

## HistoryMetrics.mqh

- **ENUM_SIMPLIFY_DEAL_KIND** SimplifyDealKind(**ENUM_DEAL_TYPE** type) - `SIMPLIFY_DEAL_TRADE`, `SIMPLIFY_DEAL_BALANCE`, `SIMPLIFY_DEAL_OTHER_OP` (credit, bonus, correction, charge) or `SIMPLIFY_DEAL_COST` (separate commission, interest, dividend, tax deals)

### CTradeStats

Public fields: key, trades, wins, losses, grossProfit, grossLoss, net, commission, swap, curve, curvePeak, maxDD, lossStreak, maxLossStreak, todayNet, todayTrades, floating, openPositions.

- AddFlow(profit, swap, commission, today) - cash flows of one trade deal
- AddTradeResult(result, today) - one closed result
- AddOpen(floating), ResetDay(), ResetOpen(), Reset(key)
- ProfitFactor(), HasProfitFactor(), Expectancy(), WinRate(), AverageWin(), AverageLoss() - all 0 when there is nothing to measure

### CDrawdown

Peak and max drawdown of a running curve: `Add(delta)` for a curve that starts at 0, `Set(level)` for a level such as the equity. Value(), Peak(), MaxDrawdown(), Drawdown().

### CPositionCosts

Entry costs (commission, fee, swap) of a position shared among its exit deals by volume.

- AddEntry(positionId, volume, cost)
- **double** TakeExitShare(positionId, volume, reversal) - share for this exit; with reversal (DEAL_ENTRY_INOUT) the remainder opens the other side
- PendingCost(positionId), OpenVolume(positionId), Count(), Reset()

## Tests

`tests/TestHistory.mq5` (script, no account needed) and `tests/TradeFreeHeaders.mq5` (build check with no trade code and no MessageBox).
