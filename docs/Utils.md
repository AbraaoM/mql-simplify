# Utils

## AcumulatedProfit

Sum all profit between two dates.

**Parameters**

* **datetime** initDate_AP
* **datetime** finishDate_AP

**Return**

* **double** profitAcum - Sum of all profit between dates

## ProfitDay

Sum all profit last day.

**Return**

* **double** profitAcum - Sum of all last day

## ProfitWeek

Sum all profit last week.

**Return**

* **double** profitAcum - Sum of all last week

## ProfitMonth

Sum all profit last month.

**Return**

* **double** profitAcum - Sum of all last month

## ProfitYear

Sum all profit last year.

**Return**

* **double** profitAcum - Sum of all last year



## CloseAllPositions

Close all opened positions on current symbol.

**Parameter**

* **string** symbol - Symbol to apply function
* **int** deviation - Price deviation to close positions

**Return**

* **void**


## DeleteAllOrders

Delete all opened orders, of all symbols.


## TrailingStop

This function runs trailing stop strategy, for one position identified by ticket, using CTrade library to modify stop loss.   

**Parameters**

* **ulong** ticket - Ticket of a open position 
* **double** stopLoss_ - Distance between current price and moving SL (points)
* **double** step = 0 - Step to new actualization of the trailing stop (points)(0 = current symbol tick size)
* **double** startLevel = 0 - Distance between position open price and current price, to start change stop loss (points) 

**Return**

* **void**


## Breakeven

Applies the breakeven point to a position identified by a ticket. The stop loss level is moved up to the position opening level using library CTrade, function .

**Parameter**

* **ulong** ticket - Ticket of an opened position
* **double** stopLoss_ - Stop loss manteined ultil breakeven is not hit (points)
* **double** step = NULL - Step to new actualization of the breakeven (points)(NULL = current symbol tick size)

**Return**

* **void**


## Martingale

Executes Martingale strategy, multiplying volume of the last open operation by a factor.

**Parameter**

* **double** factor - Multiplying factor
* **TRADE_TYPE** type - Order type for the new position
* **double** operationPrice - Price were the old position must be closed and a new oppened
* **double** stopLoss_ - Stop loss for the new position
* **double** takeProfit_ - Take profit for the new position

**Return**

* **double** newVolume - Volume of the new position (old position * factor)

## SetStopForManual

Define stop loss and take profit for the positions oppened by user (not an Expert).

**Parameter**

* **double** stopLoss_ - Stop loss (points)
* **double** takeProfit_ - Take profit (points)

**Return**

* **bool** - True if new stops are setted with no errors 

## PartialClosePercent

Partial close a position by a percentage based on price levels. 

**Parameter**

* **ulong** ticket - Ticket of an opened position
* **double** percentageRemain - Percentage of volume of a oppened position that will remain (**keep oppened**)
* **double** levelExecute - Price level to execute the partial close

**Return**

* **bool** - True if successful whithout errors

## PartialCloseAmount

Partial close a position by a volume provided on parameters.

**Parameter**

* **ulong** ticket - Ticket of an opened position
* **double** volumeToClose - Volume of the oppened position to close
* **double** levelExecute - Price level to execute the partial close

**Return**

* **bool** - True if successful whithout errors

## NumberOfTrades

Number of trades in a period of time.

**Parameter**

* **datetime** initDate - Initial date
* **datetime** finishDate - Finish date

**Return**

* **int** - Number of trades in period provided

## IsNewCandle

Detects if a new candle starts.

**Parameter**

* **ENUM_TIMEFRAMES** timeframe - Candle period (defalt: current)

**Return**

* **bool** - true if have a new a candle and false if don't

## PastOperationTicket

Get ticket of a past operation defined by a shift.

**Parameter**

* **int** shift - Shift (0: last operation)

**Return**

* **ulong** - Ticket of the past position

## HistoryDealType

Get type of a past closed position from the deal history.

**Parameter**

* **int** shift - Shift (0: last operation)

**Return**

* **TRADE_TYPE** - BUY, SELL or NOTHING, if some error happens

## HistoryDealPrice

Get price of a past closed position from the deal history.

**Parameter**

* **int** shift - Shift (0: last operation)

**Return**

* **TRADE_TYPE** - BUY, SELL or NOTHING, if some error happens

## TPDetector

Detects last position closed by take profit.

**Parameter**

**Return**

* **bool** - true if the last position was closed by take profit and false if closed by other reason

## TimeStringTokenizer

Splits a string using ":" as token, primary use is for time model string. 

Example: "HH:MM:SS" shall result ["HH", "MM", "SS"]

**Parameter**

* **string** time - String in model of time, with ":" to tokenize
* **string** &tokenizedTime[] - Refecence of a array to receive the result strings

**Return**

* **void** 

## StringTimeToInt

Turn a time model string into a int value that can be read as some like a timestamp.

**Parameter**

* **string** time - String in model of time
  * Some models: "HH:MM:SS", "HH:MM", "MM:SS", "HH", "MM" or "SS"
* **ENUM_TIME_STRING_TO_INT_TYPES** selector - Selects the type of string on first parameter, "time".
  * ENUM_TIME_STRING_TO_INT_TYPES can assume values HHMMSS, HHMM, MMSS, HH, MM or SS

**Return**

* **int** - Timestamp value corresponding to input time ofering as parameter 

## IntTimeToString

Turn a int/timestamp into a string following the model "HH:MM:SS".

**Parameter**

* **int** time - Timestamp

**Return**

* **string** - String equivalent to the timestamp, input on parameter, following the model "HH:MM:SS"

## CandleSize

Calculate the size of a candle, difference between candle open and close.

**Parameter**

* **ENUM_TIMEFRAMES** u_timeframe - Candle period (default: PERIOD_CURRENT)
* **int** u_shift - Shift of candles (0: current candle) (default: 1)

**Return**

* **double** - Difference between candle open and close, that is candle size

## IsCandlePositive

Detects if a candle, can be selected by a shift, is positive.

**Parameter**

* **ENUM_TIMEFRAMES** u_timeframe - Candle period (default: PERIOD_CURRENT)
* **int** u_shift - Shift of candles (0: current candle) (default: 1)

**Return**

* **bool** - 
  * true: Candle is positive, candle close bigger than candle open 
  * false: Candle is not positive, candle close smaller than candle open

## IsCandleNegative

Detects if a candle, can be selected by a shift, is negative.

**Parameter**

* **ENUM_TIMEFRAMES** u_timeframe - Candle period (default: PERIOD_CURRENT)
* **int** u_shift - Shift of candles (0: current candle) (default: 1)

**Return**

* **bool** - 
  * true: Candle is negative, candle close smaller than candle open 
  * false: Candle is not negative, candle close bigger than candle open

## ExpertPositions

Find on oppened positions what positions was oppened by an expert, an expert is iddentified by magic number.

**Parameter**

* **long** magicNumber - Expert magic number
* **ulong** &dest_tickets[] - Array of tickets

**Return**

* **void**

## ArrayShift

Shift all elemnts of an array.

**Parameter**

* **int** ut_shift - Size of shift that will applied on an array
* **double** &ut_buffer[] - Array that will be shifted

**Return**

* **void**

## BooleanArray

Scroll through an array of boolean elements and return true if all elements are true.

**Parameter**

* **bool&** ut_array[] - Array of booleans to evaluate

**Return**

* **bool** -
  * true: array are full true
  * false: array has at least one false value