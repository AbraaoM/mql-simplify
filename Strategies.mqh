//+------------------------------------------------------------------+
//|                                                   Strategies.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

class CStrategies {
void CStrategies :: Breakeven (ulong ticket,
                          double stopLoss,
                          double step);

};

//+------------------------------------------------------------------+
//|  Breakeven function                                              |
//+------------------------------------------------------------------+
void CStrategies :: Breakeven (ulong ticket,
                          double stopLoss_,
                          double step = NULL) {
  bool trailingControl = true;

  if(step == NULL)
    step = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

  if(PositionSelectByTicket(ticket)) {
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
      if(PositionGetDouble(POSITION_SL) >= PositionGetDouble(POSITION_PRICE_OPEN))
        trailingControl = false;
    } else {
      if(PositionGetDouble(POSITION_SL) <= PositionGetDouble(POSITION_PRICE_OPEN))
        trailingControl = false;
    }
    if(trailingControl)
      TrailingStop(ticket, stopLoss_, step, 0);
  }
}


//+------------------------------------------------------------------+
