# NewTypes

Centralize new types used by MQL Simplify library.

```c++
enum TRADE_TYPE {
  SELL = 0,       //Venda
  BUY = 1,        //Compra
  NOTHING = 2     //Nenhum
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