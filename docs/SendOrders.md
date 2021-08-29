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

## MarketOrderPoints

Open orders at market by points.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType

## MarketOrderPrice

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

## LimitOrderPrice

Put limit orders by price.

**Parameters**

- **bool&** m_requirements[]
- **TRADE_TYPE** m_tradeType
- **double** so_price