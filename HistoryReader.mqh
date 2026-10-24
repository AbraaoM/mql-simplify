//+------------------------------------------------------------------+
//|                                                HistoryReader.mqh |
//|  Incremental reader of the deal history. Each call to Read()     |
//|  delivers only the deals that were not delivered before, oldest  |
//|  first, with a work cap per call (number of deals and time), so  |
//|  a long history is loaded over several calls (OnTimer) without   |
//|  freezing the chart. No Sleep, no waiting loops, no trade code.  |
//|                                                                  |
//|  Cursor: time of the last delivered deal + the tickets already   |
//|  delivered at that same second, so deals that share a second are |
//|  neither lost nor repeated.                                      |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_HISTORY_READER_MQH
#define MQL_SIMPLIFY_HISTORY_READER_MQH

//--- receives each new deal; the history is selected during the call,
//--- so HistoryDealGet*(ticket, ...) can be used
class CDealListener {
 public:
  virtual           ~CDealListener() {}
  virtual void       OnDeal(ulong ticket) {}
};

class CHistoryReader {
 private:
  datetime           cursorTime;
  ulong              cursorTickets[];
  bool               loading;
  int                maxDeals;
  ulong              maxMicroseconds;
  int                lastNew;
  int                total;
  ulong              lastMicroseconds;
  ulong              maxSeenMicroseconds;

  bool               Seen(ulong ticket);

 public:
                     CHistoryReader();
  //--- work cap per Read() call: at least 100 deals and 5 ms
  void               Configure(int maxDealsPerCall, int maxMsPerCall);
  //--- forget everything: the next calls deliver the whole history again
  void               Reset();
  //--- delivers new deals to the listener; returns how many were delivered
  int                Read(CDealListener *listener);
  //--- true while the last call stopped at the cap (more deals are waiting)
  bool               IsLoading() const { return loading; }
  datetime           CursorTime() const { return cursorTime; }
  int                LastNewDeals() const { return lastNew; }
  int                TotalDeals() const { return total; }
  ulong              LastReadMicroseconds() const { return lastMicroseconds; }
  ulong              MaxReadMicroseconds() const { return maxSeenMicroseconds; }
};

//+------------------------------------------------------------------+
//|  Constructor: 2000 deals and 20 ms per call                      |
//+------------------------------------------------------------------+
CHistoryReader :: CHistoryReader() {
  maxDeals = 2000;
  maxMicroseconds = 20000;
  lastMicroseconds = 0;
  maxSeenMicroseconds = 0;
  Reset();
}

//+------------------------------------------------------------------+
//|  Work cap                                                        |
//+------------------------------------------------------------------+
void CHistoryReader :: Configure(int maxDealsPerCall, int maxMsPerCall) {
  maxDeals = (maxDealsPerCall < 100) ? 100 : maxDealsPerCall;
  maxMicroseconds = (ulong)((maxMsPerCall < 5) ? 5 : maxMsPerCall) * 1000;
}

//+------------------------------------------------------------------+
//|  Reset the cursor                                                |
//+------------------------------------------------------------------+
void CHistoryReader :: Reset() {
  cursorTime = 0;
  ArrayFree(cursorTickets);
  loading = true;
  lastNew = 0;
  total = 0;
}

//+------------------------------------------------------------------+
//|  Ticket already delivered at the cursor second?                  |
//+------------------------------------------------------------------+
bool CHistoryReader :: Seen(ulong ticket) {
  for(int i = 0; i < ArraySize(cursorTickets); i++)
    if(cursorTickets[i] == ticket)
      return true;
  return false;
}

//+------------------------------------------------------------------+
//|  Incremental read with a work cap                                |
//+------------------------------------------------------------------+
int CHistoryReader :: Read(CDealListener *listener) {
  ulong t0 = GetMicrosecondCount();
  bool capped = false;
  lastNew = 0;
  //--- window: from the cursor to tomorrow (the server clock can be ahead of the last quote)
  if(HistorySelect(cursorTime, TimeTradeServer() + 86400)) {
    int deals = HistoryDealsTotal();
    for(int i = 0; i < deals; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
        continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      if(t < cursorTime)
        continue;
      if(t == cursorTime) {
        if(Seen(ticket))
          continue;
      } else {
        cursorTime = t;
        ArrayResize(cursorTickets, 0, 8);
      }
      int n = ArraySize(cursorTickets);
      ArrayResize(cursorTickets, n + 1, 8);
      cursorTickets[n] = ticket;
      total++;
      if(CheckPointer(listener) != POINTER_INVALID)
        listener.OnDeal(ticket);
      lastNew++;
      if(lastNew >= maxDeals || GetMicrosecondCount() - t0 >= maxMicroseconds) {
        capped = true;
        break;
      }
    }
  }
  loading = capped;
  lastMicroseconds = GetMicrosecondCount() - t0;
  if(lastMicroseconds > maxSeenMicroseconds)
    maxSeenMicroseconds = lastMicroseconds;
  return lastNew;
}

#endif
