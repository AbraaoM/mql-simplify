//+------------------------------------------------------------------+
//|                                                   SymbolInfo.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

class CSymbolInfo {
 private:
  long sumTimeOnOperation;

 public:
  CSymbolInfo :: CSymbolInfo();
  long CSymbolInfo :: TimeOnOperation();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfo :: CSymbolInfo() {
  sumTimeOnOperation = 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CSymbolInfo :: TimeOnOperation() {
  long openTime, currentTime;

  if(PositionSelect(_Symbol)) {
    openTime = PositionGetInteger(POSITION_TIME);
    currentTime = TimeCurrent();
    sumTimeOnOperation = (currentTime - openTime);
  }
  return sumTimeOnOperation;
}
//+------------------------------------------------------------------+
