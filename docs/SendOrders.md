# SendOrders

Class CSendOrders is used to centralize utilitaries to send orders.

All methods receives a boolean array of requirements, an order will only be released if all elements of the array are true.

The second parameter of all methods are an TRADE_TYPE from NewTypes.mqh, that defines orders as BUY or SELL.

## Constructor

Initialize basic information it will be used to open orders on different ways.

**Parameters**

- **string** so_symbol = NULL
- **long** so_magicNumber = NULL
- **double** so_volume = 0
- **double** so_takeProfit = 0
- **double** so_stopLoss = 0

## AtMarketPoints

Open orders at market by points.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType

## AtMarketPrice

Open orders at market by price.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType
- **double** so_price

## StopOrderPrice

Put stop orders by price.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType
- **double** so_price

## StopOrderPoints

Put stop orders by points.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType
- **double** so_price

## LimitOrderPoints

Put limit orders by points.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType
- **double** so_price

## RevertPosition

Reverses the sense of an open position, buy to sell or sell to buy.

**Parameters**

- **bool&** m_buyRequirements[]
- **bool&** m_sellRequirements[]
- **ulong** m_ticket
- **ENUM_OPERATIONAL_TYPE** m_operationType = TYPE_POINTS

**Return**

- **bool** -
  - true: sucess, position reverted
  - false: Houston, we have a problem!

## OnBidPoints

Open a order on bid, can be a buy or sell.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType

## OnAskPoints

Open a order on ask, can be a buy or sell.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType

## GetVolume

Get volume of orders send by class.

**Return**
- **double** volume

## SetVolume

Set a new value for volume of orders send by class.

**Parameters**
- **double** newVolume

## GetStopLoss

Get stop loss of orders send by class.

**Return**
- **double** stopLoss

## SetStoploss

Set a new value for stop loss of orders send by class.

**Parameters**
- **double** newStopLoss

## GetTakeProfit

Get take profit of orders send by class.

**Return**
- **double** takeProfit

## SetTakeProfit

Set a new value for take profit of orders send by class.

**Parameters**
- **double** newTakeProfit
