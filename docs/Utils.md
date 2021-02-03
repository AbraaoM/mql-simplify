# Utils

## AcumulatedProfit

Sum all profit between two dates.

**Parameters**

* **datetime** initDate_AP
* **datetime** finishDate_AP

**Return**

* **double** profitAcum - Sum of all profit between dates

**Code**

```c++
  double CUtils :: AcumulatedProfit(datetime initDate_AP, datetime finishDate_AP) {
    double profitAcum = 0;

    HistorySelect(initDate_AP, finishDate_AP);
    for(int i = 1; i <= HistoryDealsTotal(); i++) {
      ulong ticket = HistoryDealGetTicket(i);
      profitAcum += HistoryDealGetDouble(ticket, DEAL_PROFIT);
    }
    return profitAcum;
  }
```

## CloseAllPositions

Close all opened positions on current symbol.

**Parameter**

* **string** symbol - Symbol to apply function
* **int** deviation - Price deviation to close positions

**Return**

* **void**

**Code**

```c++
 void CUtils :: CloseAllPositions(string symbol, int deviation) {
    CTrade trade_TL;
    ulong ticket = 0;
    if(PositionSelect(symbol)) {
      for(int i = 0; i < PositionsTotal(); i++) {
        ticket = PositionGetTicket(i);
        trade_TL.PositionClose(ticket, deviation);
      }
    }
  }
```

## DeleteAllOrders

Delete all opened orders, of all symbols.

**Code**
```c++
  void CUtils :: DeleteAllOrders() {
    CTrade trade_DAO;
    ulong ticket = 0;
    if(OrdersTotal() != 0) {
      for(int i = 0; i < OrdersTotal(); i++) {
        ticket = OrderGetTicket(i);
        trade_DAO.OrderDelete(ticket);
      }
    }
  }
```

## TrailingStop

This function runs trailing stop strategy, for one position identified by ticket, using CTrade library to modify stop loss.   

**Parameters**

* **ulong** ticket - Ticket of a open position 
* **double** stopLoss_ - Distance between current price and moving SL (points)
* **double** step = 0 - Step to new actualization of the trailing stop (points)(0 = current symbol tick size)
* **double** startLevel = 0 - Distance between position open price and current price, to start change stop loss (points) 

**Return**

* **void**

**Code**
```c++
 void CUtils :: TrailingStop (ulong ticket,
                               double stopLoss_,
                               double step = 0,
                               double startLevel = 0) {
    CTrade trade_TS;
    double newSL = 0;

    if(step == 0)
      step = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) / _Point;

    if(PositionSelectByTicket(ticket)) {
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
          PositionGetDouble(POSITION_PRICE_CURRENT) >= PositionGetDouble(POSITION_PRICE_OPEN) + startLevel*_Point) {
        newSL = PositionGetDouble(POSITION_PRICE_CURRENT) - stopLoss_*_Point;
        if(newSL > PositionGetDouble(POSITION_SL))
          trade_TS.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
      }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
          PositionGetDouble(POSITION_PRICE_CURRENT) <= PositionGetDouble(POSITION_PRICE_OPEN) - startLevel*_Point) {
        newSL = PositionGetDouble(POSITION_PRICE_CURRENT) + stopLoss_*_Point;
        if(newSL < PositionGetDouble(POSITION_SL))
          trade_TS.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
      }
    }
  }
```

## Breakeven

Applies the breakeven point to a position identified by a ticket. The stop loss level is moved up to the position opening level using library CTrade, function .

**Parameter**

* **ulong** ticket - Ticket of an opened position
* **double** stopLoss_ - Stop loss manteined ultil breakeven is not hit (points)
* **double** step = NULL - Step to new actualization of the breakeven (points)(NULL = current symbol tick size)

**Return**

* **void**

**Code**

```c++
  void CUtils :: Breakeven (ulong ticket,
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
```

## Martingale

Applies martingale

## SetStopForManual

## PartialClosePercent

## PartialCloseAmount

## NumberOfTrades

## IsNewCandle

## PastOperationTicket

## HistoryDealType

## HistoryDealPrice

## TPDetector


