//+------------------------------------------------------------------+
//|                                                   Strategies.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>
#include "NewTypes.mqh"

//+------------------------------------------------------------------+
//|  Rounds a volume DOWN to the symbol volume step; 0 when below the |
//|  minimum volume                                                   |
//+------------------------------------------------------------------+
double SimplifyNormalizeVolume(string symbol, double volume) {
  double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
  double vmin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
  if(step <= 0)
    return 0;
  double v = MathFloor(volume / step + 1e-9) * step;
  int digits = (int)MathMax(0, MathCeil(-MathLog10(step)));
  v = NormalizeDouble(v, digits);
  return (v < vmin) ? 0 : v;
}

//+------------------------------------------------------------------+
//|  True when the selected position moved levelExecute points in     |
//|  its favour (buy: current >= open + level, sell: current <= open  |
//|  - level). Replaces an exact '==' price comparison.               |
//+------------------------------------------------------------------+
bool SimplifyPartialLevelReached(double levelExecute) {
  double point = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);
  double open = PositionGetDouble(POSITION_PRICE_OPEN);
  double current = PositionGetDouble(POSITION_PRICE_CURRENT);
  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    return current >= open + levelExecute * point;
  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
    return current <= open - levelExecute * point;
  return false;
}

class CStrategies {
 public:
  void CStrategies :: Breakeven (ulong ticket,
                                 double stopLoss,
                                 double step);

  double CStrategies :: Martingale (double factor,
                                    TRADE_TYPE type,
                                    double operationPrice,
                                    double stopLoss,
                                    double takeProfit);

  bool CStrategies :: PartialCloseAmount(ulong ticket,
                                         double volumeToClose,
                                         double levelExecute);

  bool CStrategies :: PartialClosePercent(ulong ticket,
                                          double percentageRemain,
                                          double levelExecute);

  bool CStrategies :: SetStopsForManual(double stopLoss,
                                        double takeProfit);

  void CStrategies :: TrailingStop (ulong ticket,
                                    double stopLoss,
                                    double step = 0,
                                    double startLevel = 0);
};

//+------------------------------------------------------------------+
//|  Breakeven function                                              |
//+------------------------------------------------------------------+
void CStrategies :: Breakeven (ulong ticket,
                               double stopLoss,
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
      TrailingStop(ticket, stopLoss, step, 0);
  }
}

//+------------------------------------------------------------------+
//|  Martingale function                                             |
//+------------------------------------------------------------------+
double CStrategies :: Martingale (double factor,
                                  TRADE_TYPE type,
                                  double operationPrice,
                                  double stopLoss,
                                  double takeProfit) {
  CTrade trade_M;
  ulong ticket;
  uint total = 0;
  double lastVolume = 0, newVolume = 0;

  HistorySelect(0, TimeTradeServer());
  total = HistoryDealsTotal();

  ticket = HistoryDealGetTicket(total - 1);
  lastVolume = HistoryDealGetDouble(ticket, DEAL_VOLUME);

  HistoryDealGetInteger(ticket, DEAL_TYPE);
  newVolume = lastVolume * factor;
  if(type == BUY)
    trade_M.Buy(newVolume,
                _Symbol,
                operationPrice,
                operationPrice - stopLoss * _Point,
                operationPrice + takeProfit * _Point);
  if(type == SELL)
    trade_M.Sell(newVolume,
                 _Symbol,
                 operationPrice,
                 operationPrice + stopLoss * _Point,
                 operationPrice - takeProfit * _Point);
  return newVolume;
}

//+------------------------------------------------------------------+
//| Partial close a position based on volume                         |
//+------------------------------------------------------------------+
bool CStrategies :: PartialCloseAmount(ulong ticket,
                                       double volumeToClose,
                                       double levelExecute) {
  CTrade partialClose_trade;
  if(PositionSelectByTicket(ticket) && SimplifyPartialLevelReached(levelExecute)) {
    double volume = SimplifyNormalizeVolume(PositionGetString(POSITION_SYMBOL), volumeToClose);
    if(volume <= 0)
      return false;
    return partialClose_trade.PositionClosePartial(ticket, volume);
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Partial close a position based on percentage                    |
//+------------------------------------------------------------------+
bool CStrategies :: PartialClosePercent(ulong ticket,
                                        double percentageRemain,
                                        double levelExecute) {
  CTrade partialClose_trade;
  double volume;
  if(PositionSelectByTicket(ticket) && SimplifyPartialLevelReached(levelExecute)) {
    volume = PositionGetDouble(POSITION_VOLUME);
    //--- percentageRemain is the share that stays open (0..1): close the rest
    double toClose = SimplifyNormalizeVolume(PositionGetString(POSITION_SYMBOL),
                                             volume * (1.0 - percentageRemain));
    if(toClose <= 0 || toClose >= volume)
      return false;
    return partialClose_trade.PositionClosePartial(ticket, toClose);
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Define stops for the manual oppened positions                   |
//+------------------------------------------------------------------+
bool CStrategies :: SetStopsForManual(double stopLoss,
                                      double takeProfit) {
  CTrade setStopForManual_trade;
  ulong ticket_;

  if(PositionSelect(_Symbol)) {
    ticket_ = PositionGetInteger(POSITION_TICKET);
    if(PositionGetInteger(POSITION_REASON) == POSITION_REASON_CLIENT) {
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
          (PositionGetDouble(POSITION_SL) != PositionGetDouble(POSITION_PRICE_OPEN) - (stopLoss * _Point) ||
           PositionGetDouble(POSITION_TP) != PositionGetDouble(POSITION_PRICE_OPEN) + (takeProfit * _Point))) {
        setStopForManual_trade.PositionModify(ticket_,
                                              PositionGetDouble(POSITION_PRICE_OPEN) - (stopLoss * _Point),
                                              PositionGetDouble(POSITION_PRICE_OPEN) + (takeProfit * _Point));
      }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
          (PositionGetDouble(POSITION_SL) != PositionGetDouble(POSITION_PRICE_OPEN) + (stopLoss * _Point) ||
           PositionGetDouble(POSITION_TP) != PositionGetDouble(POSITION_PRICE_OPEN) - (takeProfit * _Point))) {
        setStopForManual_trade.PositionModify(ticket_,
                                              PositionGetDouble(POSITION_PRICE_OPEN) + (stopLoss * _Point),
                                              PositionGetDouble(POSITION_PRICE_OPEN) - (takeProfit * _Point));
      }
      return true;
    }
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Trainling stop function                                         |
//+------------------------------------------------------------------+
void CStrategies :: TrailingStop (ulong ticket,
                                  double stopLoss,
                                  double step = 0,
                                  double startLevel = 0) {
  CTrade trade_TS;
  double newSL = 0;

  if(step == 0)
    step = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) / _Point;

  if(PositionSelectByTicket(ticket)) {
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
        PositionGetDouble(POSITION_PRICE_CURRENT) >= PositionGetDouble(POSITION_PRICE_OPEN) + startLevel * _Point) {
      newSL = PositionGetDouble(POSITION_PRICE_CURRENT) - stopLoss * _Point;
      if(newSL > PositionGetDouble(POSITION_SL))
        trade_TS.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
    }
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
        PositionGetDouble(POSITION_PRICE_CURRENT) <= PositionGetDouble(POSITION_PRICE_OPEN) - startLevel * _Point) {
      newSL = PositionGetDouble(POSITION_PRICE_CURRENT) + stopLoss * _Point;
      if(newSL < PositionGetDouble(POSITION_SL))
        trade_TS.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
    }
  }
}


//+------------------------------------------------------------------+
