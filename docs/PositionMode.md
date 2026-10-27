# PositionMode.mqh

Netting ou hedging, a partir de `AccountInfoInteger(ACCOUNT_MARGIN_MODE)`. Funções puras.

Em netting (contas da B3 e retail netting) existe **uma** posição por símbolo, e uma ordem oposta reduz ou inverte essa posição. Por isso:

- `SimplifyIsNetting(modo)`: verdadeiro para `RETAIL_NETTING` e `EXCHANGE`.
- `SimplifyCanOpenEntry(netting, posiçõesNoSímbolo, posiçõesDoEA, máximo)`: em netting, só entra se o símbolo não tiver posição nenhuma (de qualquer magic), para nunca somar, reduzir ou inverter sem querer. Em hedging, entra enquanto as posições do EA estiverem abaixo do máximo.
- `SimplifyCloseOrder(tipo, volume, ordem, vol)`: a ordem que zera a posição, do lado oposto e com o volume exato.
