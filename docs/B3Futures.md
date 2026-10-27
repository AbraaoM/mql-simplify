# B3Futures.mqh

Calendário dos futuros de índice da B3 (WIN e IND). Funções puras, sem chamadas ao terminal.

Regra da B3 (especificação do contrato): o vencimento é na quarta-feira mais próxima do dia 15 do mês de vencimento (meses pares). Se esse dia não tiver pregão, a B3 passa para o pregão seguinte. **Esse ajuste por feriado não está implementado.** Prefira `SYMBOL_EXPIRATION_TIME` da corretora e use estas funções como reserva.

```cpp
#include "Lib/mql-simplify/B3Futures.mqh"
datetime exp = (datetime)SymbolInfoInteger(sym, SYMBOL_EXPIRATION_TIME);
if(exp == 0) exp = SimplifyB3ExpiryFromSymbol(sym, "WIN");   // "WINZ26" -> 2026.12.16
int days = SimplifyDaysToExpiry(TimeTradeServer(), exp);     // INT_MAX = desconhecido
if(SimplifyRollBlocksEntry(days, 5)) { /* não abra posição: contrato vencendo */ }
```

| Função | O que faz |
| --- | --- |
| `SimplifyFuturesMonth(letra)` | F G H J K M N Q U V X Z → 1..12; 0 se desconhecida |
| `SimplifyB3IndexExpiry(ano, mês)` | quarta-feira mais próxima do dia 15 |
| `SimplifyB3ExpiryFromSymbol(símbolo, raiz)` | `WINZ26`, `INDQ26`, `WINZ26.fut`; 0 para série contínua (`WIN$`, `WIN$N`) |
| `SimplifyDaysToExpiry(agora, vencimento)` | dias corridos até a data do vencimento (0 = dia do vencimento) |
| `SimplifyRollBlocksEntry(dias, N)` | bloqueia de N dias antes até o vencimento, e depois dele |

Testes: `tests/TestB3Futures.mq5`.
