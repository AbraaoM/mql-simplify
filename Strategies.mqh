//+------------------------------------------------------------------+
//|                                                   Strategies.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>
#include "NewTypes.mqh"

class CStrategies {
  void CStrategies :: Breakeven (ulong ticket,
                                 double stopLoss,
                                 double step);

  double CStrategies :: Martingale (double factor,
                                    TRADE_TYPE type,
                                    double operationPrice,
                                    double stopLoss,
                                    double takeProfit);

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
//|  Martingale function                                             |
//+------------------------------------------------------------------+
double CStrategies :: Martingale (double factor,
                                  TRADE_TYPE type,
                                  double operationPrice,
                                  double stopLoss_,
                                  double takeProfit_) {
  CTrade trade_M;
  ulong ticket;
  uint total = 0;
  double lastVolume = 0, newVolume = 0;

  HistorySelect(0, TimeLocal());
  total = HistoryDealsTotal();

  ticket = HistoryDealGetTicket(total - 1);
  lastVolume = HistoryDealGetDouble(ticket, DEAL_VOLUME);

  HistoryDealGetInteger(ticket, DEAL_TYPE);
  newVolume = lastVolume * factor;
  if(type == BUY)
    trade_M.Buy(newVolume,
                _Symbol,
                operationPrice,
                operationPrice - stopLoss_ * _Point,
                operationPrice + takeProfit_ * _Point);
  if(type == SELL)
    trade_M.Sell(newVolume,
                 _Symbol,
                 operationPrice,
                 operationPrice + stopLoss_ * _Point,
                 operationPrice - takeProfit_ * _Point);
  return newVolume;
}


//+------------------------------------------------------------------+
