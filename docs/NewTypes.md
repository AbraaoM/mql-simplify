# NewTypes

Centralize new types used by MQL Simplify library.

```c++
enum TRADE_TYPE {
  SELL = 0,       //Venda
  BUY = 1,        //Compra
  NOTHING = 2,    //Nenhum
  INDIFFERENT = 3 //Indiferente
};
```

```c++
enum BINARY_OPTIONS {
  YES = 1,    //Sim
  NO = 0,     //Não
};
```

```c++
enum OPERATION_OPTIONS {
  STOP_ORDER,     //Ordem Stop
  MARKET_ORDER    //Ordem a Mercado
};
```

```c++
enum ENUM_TIME_STRING_TO_INT_TYPES {
  HHMMSS,
  HHMM,
  MMSS,
  HH,
  MM,
  SS,
};
```

```c++
enum PRICE_TYPE {
  OPEN,   //Abertura
  HIGH,   //Máxima
  LOW,    //Mínima
  CLOSE   //Fechamento
};
```

```c++
enum BUY_SELL_TYPE {
  BUY_ON_BID_SELL_ON_ASK, //Compra no BID e venda no ASK
  BUY_ON_ASK_SELL_ON_BID  //Compra no ASK e venda no BID
};

```

```c++
enum ENUM_OPERATIONAL_TYPE {
  TYPE_PRICE,
  TYPE_POINTS
};
```