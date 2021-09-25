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
  long m_magicNumber;
  string m_symbol;
  double m_volume,
         m_takeProfit,
         m_stopLoss;
  BUY_SELL_TYPE m_buySellType;

  CTrade *trade_SO;
  CUtils *utils_SO;

 public:
  CSendOrders(string so_symbol = NULL,
              long so_magicNumber = NULL,
              double so_volume = 0,
              double so_takeProfit = 0,
              double so_stopLoss = 0,
              BUY_SELL_TYPE so_buySellType = BUY_ON_ASK_SELL_ON_BID);

  ~CSendOrders();

  void MarketOrderPoints(bool& m_requirements[],
                         TRADE_TYPE m_tradeType);

  bool MarketOrderPrice(bool& m_requirements[],
                        TRADE_TYPE m_tradeType);

  bool StopOrderPrice(bool& m_requirements[],
                      TRADE_TYPE m_tradeType,
                      double so_price);

  bool LimitOrderPrice(bool& m_requirements[],
                       TRADE_TYPE m_tradeType,
                       double so_price);

  bool RevertPosition(bool& m_buyRequirements[],
                      bool& m_sellRequirements[],
                      ulong m_ticket,
                      ENUM_OPERATIONAL_TYPE m_operationType = TYPE_POINTS);
};

//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
CSendOrders :: CSendOrders(string so_symbol = NULL,
                           long so_magicNumber = NULL,
                           double so_volume = 0,
                           double so_takeProfit = 0,
                           double so_stopLoss = 0,
                           BUY_SELL_TYPE so_buySellType = BUY_ON_ASK_SELL_ON_BID) {
  m_magicNumber = so_magicNumber;
  m_symbol = so_symbol;
  m_volume = so_volume;
  m_takeProfit = so_takeProfit;
  m_stopLoss = so_stopLoss;
  m_buySellType = so_buySellType;

  trade_SO = new CTrade();
  trade_SO.SetExpertMagicNumber(m_magicNumber);

  utils_SO = new CUtils();
}

//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
CSendOrders :: ~CSendOrders() {
  delete trade_SO;
  delete utils_SO;
}


//+------------------------------------------------------------------+
//|  Send orders at market, parameter points                         |
//+------------------------------------------------------------------+
void CSendOrders :: MarketOrderPoints(bool& m_requirements[],
                                      TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return;

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);

  if(m_buySellType == BUY_ON_BID_SELL_ON_ASK) {
    if(m_tradeType == SELL) {
      trade_SO.Sell(m_volume,
                    m_symbol,
                    ask_SO,
                    (m_stopLoss == 0) ? 0 : ask_SO + (m_stopLoss * _Point),
                    (m_takeProfit == 0) ? 0 : ask_SO - (m_takeProfit * _Point));
    }
    if(m_tradeType == BUY) {
      trade_SO.Buy(m_volume,
                   m_symbol,
                   bid_SO,
                   (m_stopLoss == 0) ? 0 : bid_SO - (m_stopLoss * _Point),
                   (m_takeProfit == 0) ? 0 : bid_SO + (m_takeProfit * _Point));
    }
  } else {
    if(m_tradeType == SELL) {
      trade_SO.Sell(m_volume,
                    m_symbol,
                    bid_SO,
                    (m_stopLoss == 0) ? 0 : bid_SO + (m_stopLoss * _Point),
                    (m_takeProfit == 0) ? 0 : bid_SO - (m_takeProfit * _Point));
    }
    if(m_tradeType == BUY) {
      trade_SO.Buy(m_volume,
                   m_symbol,
                   ask_SO,
                   (m_stopLoss == 0) ? 0 : ask_SO - (m_stopLoss * _Point),
                   (m_takeProfit == 0) ? 0 : ask_SO + (m_takeProfit * _Point));
    }
  }
}

//+------------------------------------------------------------------+
//|  Send orders at market, parameter price                          |
//+------------------------------------------------------------------+
bool CSendOrders :: MarketOrderPrice(bool& m_requirements[],
                                     TRADE_TYPE m_tradeType) {
  for(int i = 0; i < ArrayRange(m_requirements, 0); i++)
    if(m_requirements[i] == false)
      return false;

  double ask_SO,
         bid_SO;

  ask_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), _Digits);
  bid_SO = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), _Digits);

  if(m_buySellType == BUY_ON_BID_SELL_ON_ASK) {
    if(m_tradeType == SELL) {
      trade_SO.Sell(m_volume,
                    m_symbol,
                    ask_SO,
                    m_stopLoss,
                    m_takeProfit);
    }
    if(m_tradeType == BUY) {
      trade_SO.Buy(m_volume,
                   m_symbol,
                   bid_SO,
                   m_stopLoss,
                   m_takeProfit);
    }
  } else {
    if(m_tradeType == SELL) {
      trade_SO.Sell(m_volume,
                    m_symbol,
                    bid_SO,
                    m_stopLoss,
                    m_takeProfit);
    }
    if(m_tradeType == BUY) {
      trade_SO.Buy(m_volume,
                   m_symbol,
                   ask_SO,
                   m_stopLoss,
                   m_takeProfit);
    }
    return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//|  Send ordens stop                                                |
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
//|  Send orders limit                                               |
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
//|  Revert position                                                 |
//+------------------------------------------------------------------+
bool CSendOrders :: RevertPosition(bool& m_buyRequirements[],
                                   bool& m_sellRequirements[],
                                   ulong m_ticket,
                                   ENUM_OPERATIONAL_TYPE m_operationType = TYPE_POINTS) {
  if(PositionSelectByTicket(m_ticket)) {
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
        utils_SO.BooleanArray(m_sellRequirements)) {
      trade_SO.PositionClose(m_ticket);

      if(m_operationType == TYPE_POINTS)
        MarketOrderPoints(m_sellRequirements, SELL);
      if(m_operationType == TYPE_PRICE)
        MarketOrderPrice(m_sellRequirements, SELL);
      return true;
    }
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
        utils_SO.BooleanArray( m_buyRequirements)) {
      trade_SO.PositionClose(m_ticket);

      if(m_operationType == TYPE_POINTS)
        MarketOrderPoints(m_buyRequirements, BUY);
      if(m_operationType == TYPE_PRICE)
        MarketOrderPrice(m_buyRequirements, BUY);
      return true;
    }
  }
  return false;
}

//+------------------------------------------------------------------+
