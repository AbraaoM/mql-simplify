//+------------------------------------------------------------------+
//|                                                   DealGroups.mqh |
//|  Trade statistics grouped by magic number, by a name per magic   |
//|  (map "1001=Trend;1002=Grid") or by symbol. A position belongs   |
//|  to the group of its first deal (the entry), so later deals of   |
//|  the same position stay in that group even if their magic        |
//|  differs. No trade code.                                         |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_DEAL_GROUPS_MQH
#define MQL_SIMPLIFY_DEAL_GROUPS_MQH

#include <Generic\HashMap.mqh>
#include "HistoryMetrics.mqh"

enum ENUM_DEAL_GROUP_MODE {
  DEAL_GROUP_MAGIC = 0,   // By magic number
  DEAL_GROUP_NAME = 1,    // By name (magic map)
  DEAL_GROUP_SYMBOL = 2   // By symbol
};

class CDealGroups {
 private:
  ENUM_DEAL_GROUP_MODE mode;
  CHashMap<long, string> names;        // magic -> name
  CHashMap<string, int> index;         // key -> group
  CHashMap<ulong, string> positionKey; // position id -> key
  CTradeStats        groups[];
  string             manualLabel;
  string             magicLabel;
  int                maxNameLength;

 public:
                     CDealGroups();
  //--- map format: "1001=Trend;1002=Grid" (used in DEAL_GROUP_NAME mode; other magics keep their number)
  void               Configure(ENUM_DEAL_GROUP_MODE newMode, string magicMap = "");
  //--- texts of the keys: magic 0 and the prefix of the other magics
  void               SetLabels(string manual, string magicPrefix) { manualLabel = manual; magicLabel = magicPrefix; }
  int                ParseNames(string magicMap);
  bool               NameOf(long magic, string &name) { return names.TryGetValue(magic, name); }
  //--- forget all groups and positions (the names stay)
  void               Reset();
  string             KeyFor(long magic, string symbol);
  //--- group index of a position: the first call with remember=true fixes the key
  //--- (entry deal); remember=false only looks up (open positions, unknown exits)
  int                GroupOfPosition(ulong positionId, long magic, string symbol, bool remember = true);
  //--- group index of a key (created when new)
  int                Group(string key);
  int                Count() const { return ArraySize(groups); }
  CTradeStats       *At(int i) { return (i >= 0 && i < ArraySize(groups)) ? GetPointer(groups[i]) : NULL; }
  void               ResetDay();
  void               ResetOpen();
  //--- indexes sorted by net + floating, highest first; returns the count
  int                Sorted(int &idx[]);
};

CDealGroups :: CDealGroups() {
  mode = DEAL_GROUP_MAGIC;
  manualLabel = "Manual (magic 0)";
  magicLabel = "Magic ";
  maxNameLength = 24;
}

void CDealGroups :: Configure(ENUM_DEAL_GROUP_MODE newMode, string magicMap = "") {
  mode = newMode;
  ParseNames(magicMap);
  Reset();
}

int CDealGroups :: ParseNames(string magicMap) {
  names.Clear();
  string items[];
  int n = StringSplit(magicMap, ';', items);
  for(int i = 0; i < n; i++) {
    string kv[];
    if(StringSplit(items[i], '=', kv) != 2)
      continue;
    StringTrimLeft(kv[0]);
    StringTrimRight(kv[0]);
    StringTrimLeft(kv[1]);
    StringTrimRight(kv[1]);
    if(StringLen(kv[0]) == 0 || StringLen(kv[1]) == 0)
      continue;
    long magic = StringToInteger(kv[0]);
    if(!names.ContainsKey(magic))
      names.Add(magic, StringSubstr(kv[1], 0, maxNameLength));
  }
  return names.Count();
}

void CDealGroups :: Reset() {
  index.Clear();
  positionKey.Clear();
  ArrayFree(groups);
}

string CDealGroups :: KeyFor(long magic, string symbol) {
  if(mode == DEAL_GROUP_SYMBOL)
    return symbol;
  string name;
  if(mode == DEAL_GROUP_NAME && names.TryGetValue(magic, name))
    return name;
  if(magic == 0)
    return manualLabel;
  return magicLabel + IntegerToString(magic);
}

int CDealGroups :: Group(string key) {
  int i;
  if(index.TryGetValue(key, i))
    return i;
  i = ArraySize(groups);
  ArrayResize(groups, i + 1, 32);
  groups[i].Reset(key);
  index.Add(key, i);
  return i;
}

int CDealGroups :: GroupOfPosition(ulong positionId, long magic, string symbol, bool remember = true) {
  string key;
  if(!positionKey.TryGetValue(positionId, key)) {
    key = KeyFor(magic, symbol);
    if(remember)
      positionKey.Add(positionId, key);
  }
  return Group(key);
}

void CDealGroups :: ResetDay() {
  for(int i = 0; i < ArraySize(groups); i++)
    groups[i].ResetDay();
}

void CDealGroups :: ResetOpen() {
  for(int i = 0; i < ArraySize(groups); i++)
    groups[i].ResetOpen();
}

int CDealGroups :: Sorted(int &idx[]) {
  int n = ArraySize(groups);
  ArrayResize(idx, n);
  for(int i = 0; i < n; i++)
    idx[i] = i;
  //--- insertion sort: stable, small n
  for(int i = 1; i < n; i++) {
    int v = idx[i];
    double kv = groups[v].net + groups[v].floating;
    int j = i - 1;
    while(j >= 0 && groups[idx[j]].net + groups[idx[j]].floating < kv) {
      idx[j + 1] = idx[j];
      j--;
    }
    idx[j + 1] = v;
  }
  return n;
}

#endif
