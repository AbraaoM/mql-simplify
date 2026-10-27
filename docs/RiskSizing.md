# RiskSizing.mqh

Lote a partir do dinheiro em risco e da distância do stop. Trade-free: os valores do símbolo entram como parâmetros.

```cpp
#include "Lib/mql-simplify/RiskSizing.mqh"
double lot = SimplifyLotForRisk(AccountInfoDouble(ACCOUNT_BALANCE) * 0.005, slDistance,
                                SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE),
                                SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS),
                                SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
                                SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
                                SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
if(lot == 0) { /* risco pequeno demais para o lote mínimo: não opere */ }
```

O volume é sempre arredondado **para baixo**. Nunca sobe para o mínimo, então o risco nunca passa do pedido.
`SimplifyMinStopDistance(stopsLevel, freezeLevel, point, extra)` devolve a distância mínima de SL/TP aceita pela corretora.

`SimplifyPointsToMoney(points, point, tickSize, tickValue, volume)` converte distância em pontos para dinheiro, e `SimplifyMoneyToPoints(...)` faz o inverso. Exemplo no mini índice (WIN): ponto 1, tick 5, valor do tick R$ 1,00, então 100 pontos valem R$ 20,00 por contrato (R$ 0,20 por ponto).
