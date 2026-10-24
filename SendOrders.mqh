//+------------------------------------------------------------------+
//|                                                 SimpleOrders.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>

#include "NewTypes.mqh"
#include "Utils.mqh"

class CSendOrders {
 private:
  long               m_magicNumber;
  string             m_symbol;
  double m_volume,
         m_takeProfit,
         m_stopLoss;

  CTrade             *trade_SO;
  CUtils             utilsService;

  void               SetFilling();
  bool               CanOpen(TRADE_TYPE type, double price);

 public:
                     CSendOrders(string so_symbol = NULL,
              long so_magicNumber = NULL,
              double so_volume = 0,
              double so_takeProfit = 0,
              double so_stopLoss = 0);

                    ~CSendOrders();

  void               OnBidPoints(bool& m_requirements[],
                                 TRADE_TYPE m_tradeType);

  void               OnAskPoints(bool& m_requirements[],
                                 TRADE_TYPE m_tradeType);

  void               AtMarketPoints(bool& m_requirements[],
                                    TRADE_TYPE m_tradeType);

  bool               AtMarketPrice(bool& m_requirements[],
                                   TRADE_TYPE m_tradeType);

  bool               StopOrderPrice(bool& m_requirements[],
                                    TRADE_TYPE m_tradeType,
                                    double so_price);
  bool               StopOrderPoints(bool& m_requirements[],
                                     TRADE_TYPE m_tradeType,
                                     double so_price);

  bool               LimitOrderPrice(bool& m_requirements[],
                                     TRADE_TYPE m_tradeType,
                                     double so_price);

  bool               LimitOrderPoints(bool& m_requirements[],
                                      TRADE_TYPE m_tradeType,
                                      double so_price);

  bool               RevertPosition(bool& m_buyRequirements[],
                                    bool& m_sellRequirements[],
                                    ulong m_ticket,
                                    ENUM_OPERATIONAL_TYPE m_operationType = TYPE_POINTS);
  double             GetVolume();
  void               SetVolume(double newVolume);

  double             GetStopLoss();
  void               SetStopLoss(double newStopLoss);

  double             GetTakeProfit();
  void               SetTakeProfit(double newTakeProfit);
};

//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
CSendOrders :: CSendOrders(string so_symbol = NULL,
                           long so_magicNumber = NULL,
                           double so_volume = 0,
                           double so_takeProfit = 0,
                           double so_stopLoss = 0) {
  m_magicNumber = so_magicNumber;
  m_symbol = so_symbol;
  m_volume = so_volume;
  m_takeProfit = so_takeProfit;
  m_stopLoss = so_stopLoss;

  trade_SO = new CTrade();
  trade_SO.SetExpertMagicNumber(m_magicNumber);
}

//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
CSendOrders :: ~CSendOrders() {
  delete trade_SO;
}


//+------------------------------------------------------------------+
//|  Filling mode: FOK as before when the symbol allows it, otherwise |
//|  the mode the symbol supports (a fixed FOK is rejected on many    |
//|  servers with "unsupported filling mode")                         |
//+------------------------------------------------------------------+
void CSendOrders :: SetFilling() {
  string symbol = (m_symbol == NULL || m_symbol == "") ? _Symbol : m_symbol;
  long modes = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
  if((modes & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
    trade_SO.SetTypeFilling(ORDER_FILLING_FOK);
  else
    trade_SO.SetTypeFillingBySymbol(symbol);
}

//+------------------------------------------------------------------+
//|  Checks volume limits/step and free margin before a market order  |
//|  (MQL5 Market validation, article 2555). Prints why and returns   |
//|  false instead of sending an order the server would reject.       |
//+------------------------------------------------------------------+
bool CSendOrders :: CanOpen(TRADE_TYPE type, double price) {
  string symbol = (m_symbol == NULL || m_symbol == "") ? _Symbol : m_symbol;
  double vmin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
  double vmax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
  double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
  if(m_volume < vmin || m_volume > vmax ||
      (step > 0 && MathAbs(MathRound(m_volume / step) * step - m_volume) > 1e-7)) {
    Print(__FUNCTION__, ": invalid volume ", DoubleToString(m_volume, 2), " for ", symbol);
    return false;
  }
  double margin = 0;
  ENUM_ORDER_TYPE orderType = (type == BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  if(!OrderCalcMargin(orderType, symbol, m_volume, price, margin)) {
    Print(__FUNCTION__, ": OrderCalcMargin failed, error ", GetLastError());
    return false;
  }
  if(margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)) {
    Print(__FUNCTION__, ": not enough money for ", DoubleToString(m_volume, 2), " ", symbol);
    return false;
  }
  return true;
}

//+------------------------------------------------------------------+
//|  Send orders at market, parameter points                         |
//+------------------------------------------------------------------+
void CSendOrders :: AtMarketPoints(bool& m_requirements[],
                                   TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return;

  trade_SO.SetDeviationInPoints(INT_MAX);
  SetFilling();

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);

  if(m_tradeType == SELL) {
    if(!CanOpen(m_tradeType, bid_SO))
      return;
    trade_SO.Sell(m_volume,
                  m_symbol,
                  bid_SO,
                  (m_stopLoss == 0) ? 0 : bid_SO + (m_stopLoss * _Point),
                  (m_takeProfit == 0) ? 0 : bid_SO - (m_takeProfit * _Point));
  }
  if(m_tradeType == BUY) {
    if(!CanOpen(m_tradeType, ask_SO))
      return;
    trade_SO.Buy(m_volume,
                 m_symbol,
                 ask_SO,
                 (m_stopLoss == 0) ? 0 : ask_SO - (m_stopLoss * _Point),
                 (m_takeProfit == 0) ? 0 : ask_SO + (m_takeProfit * _Point));
  }
}

//+------------------------------------------------------------------+
//|  Send orders at market, parameter price                          |
//+------------------------------------------------------------------+
bool CSendOrders :: AtMarketPrice(bool& m_requirements[],
                                  TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  trade_SO.SetDeviationInPoints(INT_MAX);
  SetFilling();

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);

  if(m_tradeType == SELL) {
    if(!CanOpen(m_tradeType, bid_SO))
      return false;
    trade_SO.Sell(m_volume,
                  m_symbol,
                  bid_SO,
                  m_stopLoss,
                  m_takeProfit);
  }
  if(m_tradeType == BUY) {
    if(!CanOpen(m_tradeType, ask_SO))
      return false;
    trade_SO.Buy(m_volume,
                 m_symbol,
                 ask_SO,
                 m_stopLoss,
                 m_takeProfit);
  }
  return true;
}

//+------------------------------------------------------------------+
//|  Send ordens stop by price                                       |
//+------------------------------------------------------------------+
bool CSendOrders :: StopOrderPrice(bool& m_requirements[],
                                   TRADE_TYPE m_tradeType,
                                   double so_price) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  if(m_tradeType == SELL) {
    return trade_SO.SellStop(m_volume, so_price, m_symbol, m_stopLoss, m_takeProfit);
  }
  if(m_tradeType == BUY) {
    return trade_SO.BuyStop(m_volume, so_price, m_symbol, m_stopLoss, m_takeProfit);
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Send ordens stop by points                                      |
//+------------------------------------------------------------------+
bool CSendOrders :: StopOrderPoints(bool& m_requirements[],
                                    TRADE_TYPE m_tradeType,
                                    double so_price) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  if(m_tradeType == SELL) {
    return trade_SO.SellStop(m_volume,
                             so_price,
                             m_symbol,
                             (m_stopLoss == 0) ? 0 : so_price + (m_stopLoss * _Point),
                             (m_takeProfit == 0) ? 0 : so_price - (m_takeProfit * _Point));
  }
  if(m_tradeType == BUY) {
    return trade_SO.BuyStop(m_volume,
                            so_price,
                            m_symbol,
                            (m_stopLoss == 0) ? 0 : so_price - (m_stopLoss * _Point),
                            (m_takeProfit == 0) ? 0 : so_price + (m_takeProfit * _Point));
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Send orders limit by price                                      |
//+------------------------------------------------------------------+
bool CSendOrders :: LimitOrderPrice(bool& m_requirements[],
                                    TRADE_TYPE m_tradeType,
                                    double so_price) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  if(m_tradeType == SELL) {
    trade_SO.SellLimit(m_volume, so_price, m_symbol, m_stopLoss, m_takeProfit);
    return true;
  }
  if(m_tradeType == BUY) {
    trade_SO.BuyLimit(m_volume, so_price, m_symbol, m_stopLoss, m_takeProfit);
    return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Send orders limit by points                                     |
//+------------------------------------------------------------------+
bool CSendOrders :: LimitOrderPoints(bool& m_requirements[],
                                     TRADE_TYPE m_tradeType,
                                     double so_price) {

  trade_SO.SetDeviationInPoints((ulong)(_Point));
  SetFilling();

  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  if(m_tradeType == SELL) {
    trade_SO.SellLimit(m_volume,
                       so_price,
                       m_symbol,
                       (m_stopLoss == 0) ? 0 : so_price + (m_stopLoss * _Point),
                       (m_takeProfit == 0) ? 0 : so_price - (m_takeProfit * _Point));
    return true;
  }
  if(m_tradeType == BUY) {
    trade_SO.BuyLimit(m_volume,
                      so_price,
                      m_symbol,
                      (m_stopLoss == 0) ? 0 : so_price - (m_stopLoss * _Point),
                      (m_takeProfit == 0) ? 0 : so_price + (m_takeProfit * _Point));
    return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Revert position                                                 |
//+------------------------------------------------------------------+
bool CSendOrders :: RevertPosition(bool& m_buyRequirements[],
                                   bool& m_sellRequirements[],
                                   ulong m_ticket,
                                   ENUM_OPERATIONAL_TYPE m_operationType = TYPE_POINTS) {
  if(PositionSelectByTicket(m_ticket)) {
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
        utilsService.BooleanArray(m_sellRequirements)) {
      trade_SO.PositionClose(m_ticket);

      if(m_operationType == TYPE_POINTS)
        AtMarketPoints(m_sellRequirements, SELL);
      if(m_operationType == TYPE_PRICE)
        AtMarketPrice(m_sellRequirements, SELL);
      return true;
    }
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
        utilsService.BooleanArray( m_buyRequirements)) {
      trade_SO.PositionClose(m_ticket);

      if(m_operationType == TYPE_POINTS)
        AtMarketPoints(m_buyRequirements, BUY);
      if(m_operationType == TYPE_PRICE)
        AtMarketPrice(m_buyRequirements, BUY);
      return true;
    }
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Open position on Bid (Buy or Sell)                              |
//+------------------------------------------------------------------+
void CSendOrders :: OnBidPoints(bool& m_requirements[],
                                TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return;

  trade_SO.SetDeviationInPoints((ulong)(_Point));
  SetFilling();

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);

  if(m_tradeType == BUY) {
    if(!CanOpen(m_tradeType, bid_SO))
      return;
    trade_SO.Buy(m_volume,
                 m_symbol,
                 bid_SO,
                 (m_stopLoss == 0) ? 0 : bid_SO - (m_stopLoss * _Point),
                 (m_takeProfit == 0) ? 0 : bid_SO + (m_takeProfit * _Point));
  }
  if(m_tradeType == SELL) {
    if(!CanOpen(m_tradeType, bid_SO))
      return;
    trade_SO.Sell(m_volume,
                  m_symbol,
                  bid_SO,
                  (m_stopLoss == 0) ? 0 : bid_SO + (m_stopLoss * _Point),
                  (m_takeProfit == 0) ? 0 : bid_SO - (m_takeProfit * _Point));
  }

}

//+------------------------------------------------------------------+
//|  Open position on Ask (Buy or Sell)                              |
//+------------------------------------------------------------------+
void CSendOrders :: OnAskPoints(bool& m_requirements[],
                                TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return;

  trade_SO.SetDeviationInPoints((ulong)(_Point));
  SetFilling();

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);
  if(m_tradeType == BUY) {
    if(!CanOpen(m_tradeType, ask_SO))
      return;
    trade_SO.Buy(m_volume,
                 m_symbol,
                 ask_SO,
                 (m_stopLoss == 0) ? 0 : ask_SO - (m_stopLoss * _Point),
                 (m_takeProfit == 0) ? 0 : ask_SO + (m_takeProfit * _Point));
  }
  if(m_tradeType == SELL) {
    if(!CanOpen(m_tradeType, ask_SO))
      return;
    trade_SO.Sell(m_volume,
                  m_symbol,
                  ask_SO,
                  (m_stopLoss == 0) ? 0 : ask_SO + (m_stopLoss * _Point),
                  (m_takeProfit == 0) ? 0 : ask_SO - (m_takeProfit * _Point));
  }
}


//+------------------------------------------------------------------+
//|  Manipulators volume                                             |
//+------------------------------------------------------------------+
double CSendOrders :: GetVolume() {
  return m_volume;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSendOrders :: SetVolume(double newVolume) {
  m_volume = newVolume;
}

//+------------------------------------------------------------------+
//|  Manipulators stop loss                                          |
//+------------------------------------------------------------------+
double CSendOrders :: GetStopLoss() {
  return m_stopLoss;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSendOrders :: SetStopLoss(double newStopLoss) {
  m_stopLoss = newStopLoss;
}

//+------------------------------------------------------------------+
//|  Manipulators take profit                                        |
//+------------------------------------------------------------------+
double CSendOrders :: GetTakeProfit() {
  return m_takeProfit;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSendOrders :: SetTakeProfit(double newTakeProfit) {
  m_takeProfit = newTakeProfit;
}
//+------------------------------------------------------------------+
