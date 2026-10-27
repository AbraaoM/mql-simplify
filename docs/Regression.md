# Regression.mqh

Regressão linear por mínimos quadrados numa janela de valores. Trade-free, sem chamadas ao terminal.

```cpp
#include "Lib/mql-simplify/Regression.mqh"
double c[]; CopyClose(_Symbol, PERIOD_H1, 1, 100, c);   // índice 0 = mais antigo
SimplifyLinRegResult r;
if(SimplifyLinRegLast(c, 100, r)) {
  double upper = SimplifyLinRegUpper(r, 2.0);   // r.last + 2 * r.stdev
  double score = SimplifyLinRegTrendScore(r);   // movimento da reta na janela, em desvios-padrão
}
```

| Campo | Significado |
|---|---|
| `slope` | variação de preço por barra |
| `intercept` / `last` | valor da reta na barra mais antiga / mais nova da janela |
| `stdev` | desvio-padrão dos resíduos (população) |
| `r2` | coeficiente de determinação (0 quando a série é plana) |
