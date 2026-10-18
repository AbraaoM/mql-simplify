//+------------------------------------------------------------------+
//|                                               TestDealGroups.mq5 |
//|  Runtime tests (script, no account needed) for DealGroups.       |
//|  Writes MQL5\\Files\\mqlsimplify_groups_results.txt.               |
//+------------------------------------------------------------------+
#include "../DealGroups.mqh"

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

void OnStart() {
  fileHandle = FileOpen("mqlsimplify_groups_results.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
  CDealGroups g;
  string nm;
  Check("parse_count", g.ParseNames("1001=Trend; 1002 = Grid ;bad;=x;1003=;1001=Dup;1004=ABCDEFGHIJKLMNOPQRSTUVWXYZ") == 3);
  Check("parse_trim", g.NameOf(1002, nm) && nm == "Grid");
  Check("parse_first_wins", g.NameOf(1001, nm) && nm == "Trend");
  Check("parse_cut_24", g.NameOf(1004, nm) && StringLen(nm) == 24);
  Check("parse_missing", !g.NameOf(7, nm));

  g.Configure(DEAL_GROUP_MAGIC, "1001=Trend");
  Check("key_magic", g.KeyFor(1001, "EURUSD") == "Magic 1001");
  Check("key_manual", g.KeyFor(0, "EURUSD") == "Manual (magic 0)");
  g.Configure(DEAL_GROUP_NAME, "1001=Trend");
  Check("key_name", g.KeyFor(1001, "EURUSD") == "Trend");
  Check("key_name_fallback", g.KeyFor(1002, "EURUSD") == "Magic 1002");
  g.Configure(DEAL_GROUP_SYMBOL);
  Check("key_symbol", g.KeyFor(1001, "XAUUSD") == "XAUUSD");
  g.SetLabels("Hand", "M#");
  g.Configure(DEAL_GROUP_MAGIC);
  Check("labels", g.KeyFor(0, "") == "Hand" && g.KeyFor(5, "") == "M#5");
  g.SetLabels("Manual (magic 0)", "Magic ");

  //--- a position stays in the group of its entry
  int a = g.GroupOfPosition(10, 1001, "EURUSD");
  int b = g.GroupOfPosition(10, 2002, "EURUSD");
  Check("position_keeps_entry_group", a == b && g.Count() == 1);
  int c = g.GroupOfPosition(11, 2002, "EURUSD", false);
  Check("lookup_does_not_remember", g.GroupOfPosition(11, 3003, "EURUSD", false) != c && g.Count() == 3);
  Check("at_valid", g.At(a) != NULL && g.At(a).key == "Magic 1001");
  Check("at_invalid", g.At(99) == NULL && g.At(-1) == NULL);

  g.At(a).AddFlow(10, 0, -1, true);
  g.At(a).AddTradeResult(9, true);
  g.At(c).AddFlow(30, 0, 0, false);
  g.At(c).AddOpen(-25);
  int d = g.Group("Magic 3003");
  g.At(d).AddFlow(2, 0, 0, true);
  int idx[];
  Check("sorted_count", g.Sorted(idx) == 3);
  //--- net + floating: a = 9, c = 5, d = 2
  Check("sorted_order", idx[0] == a && idx[1] == c && idx[2] == d);
  g.ResetDay();
  Check("reset_day", g.At(a).todayNet == 0 && g.At(a).todayTrades == 0 && g.At(a).trades == 1);
  g.ResetOpen();
  Check("reset_open", g.At(c).floating == 0 && g.At(c).openPositions == 0);
  g.Reset();
  Check("reset", g.Count() == 0 && g.NameOf(1001, nm) == false);
  g.Configure(DEAL_GROUP_NAME, "1001=Trend");
  g.Reset();
  Check("reset_keeps_names", g.NameOf(1001, nm) && nm == "Trend");

  Out(StringFormat("RESULT %s: %d passed, %d failed", failed == 0 ? "PASS" : "FAIL", passed, failed));
  if(fileHandle != INVALID_HANDLE)
    FileClose(fileHandle);
}
