# DealMath

Trade-free helpers for deal results. The file has no `CTrade` and no `OrderSend`, so it can be included by indicators and read-only tools. `Operations.mqh` includes it, so `COperations` users get the same functions as before.

## SimplifyDealResult

Trading result of one deal: profit + commission + swap + fee. Only buy/sell deals count; balance, credit and the other non-trade deals return 0.

**Parameters**

- **ENUM_DEAL_TYPE** type, **double** profit, **double** commission, **double** swap, **double** fee

or

- **ulong** ticket - history deal ticket (the history must be selected)

## SimplifyIsTradeDeal

**Return**

- **bool** - true for buy/sell deals

## SimplifyHistoryProfit

Sum of the trading results of the deals between two dates (all symbols). Selects the history of the period.

**Parameters**

- **datetime** initDate
- **datetime** finishDate

## SimplifyFloatingProfit

Floating result (profit + swap) of every open position on the symbol.

**Parameters**

- **string** symbol - NULL or "" = current symbol
