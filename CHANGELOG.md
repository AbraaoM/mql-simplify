# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Unreleased]

### Adicionado
- `Regression.mqh`: regressão linear pura (inclinação, intercepto, valor na última barra, desvio-padrão dos resíduos, R², inclinação normalizada) e bandas do canal.
- `RiskSizing.mqh`: lote por risco em dinheiro com piso no passo, teto no máximo e 0 abaixo do mínimo; distância mínima de stop (stops/freeze level); arredondamento ao tick.
- Teste `tests/TestRegressionSizing.mq5`.
- `B3Futures.mqh`: vencimento dos futuros de índice da B3 (quarta-feira mais próxima do dia 15), código do contrato (`WINZ26`), dias até o vencimento e regra de rolagem.
- `PositionMode.mqh`: netting ou hedging pelo `ACCOUNT_MARGIN_MODE`, decisão de entrada sem duplicar nem inverter, e ordem de zeragem com volume exato.
- `RiskSizing.mqh`: `SimplifyPointsToMoney` e `SimplifyMoneyToPoints`.
- Teste `tests/TestB3Futures.mq5`.
- `DayClock.mqh` (`CDayClock`): dia de trading no horário do servidor, com hora de virada.
- `HistoryReader.mqh` (`CHistoryReader`, `CDealListener`): leitura incremental do histórico, com limite de negócios e de tempo por chamada.
- `HistoryMetrics.mqh` (`CDrawdown`, `CTradeStats`, `CPositionCosts`): drawdown, fator de lucro, expectativa, taxa de acerto e custos de entrada.
- `DealGroups.mqh` (`CDealGroups`): estatísticas por magic, por nome de magic ou por símbolo.
- `DealMath.mqh`: resultado de negócios e lucro flutuante sem funções de trade.
- `Messages.mqh` (`SimplifyMessageBox`): `Alert` em indicadores e `MessageBox` em EAs e scripts.
- Testes em `tests/`: `TradeFreeHeaders`, `TestDealGroups`, `TestHistory` e `TestReviewFixes`.
- `.gitattributes`: os arquivos `.mqh` e `.mq5` usam LF.

### Alterado
- Os 7 headers que estavam em UTF-16 (Graphic, InputCheck, Limitations, NewTypes, SendOrders, Storage e SymbolInfo) foram convertidos para UTF-8 com BOM e LF. O código não mudou.
- Dias e horas usam o horário do servidor (`TimeTradeServer`) em vez do relógio do PC.
- `CSendOrders`:
  - O modo de preenchimento é escolhido pelo símbolo: FOK quando o símbolo permite, senão o primeiro modo aceito.
  - Antes de uma ordem a mercado, verifica o volume (mínimo, máximo e passo) e a margem livre. Se a verificação falhar, a ordem não é enviada e o motivo vai para o log. Esses são os requisitos de validação do Market.
- `CStrategies::Martingale` arredonda o volume ao passo do símbolo. A ordem não é enviada quando não há histórico ou quando o volume fica abaixo do mínimo.
- `SimplifyMessageBox` saiu de `NewTypes.mqh` e foi para `Messages.mqh`.

### Corrigido
- Correções para o build 6272: erros de compilação, cálculos e posições.
- `CTimeManipulation::StringTimeToInt`: uma string malformada agora retorna 0. Antes causava *array out of range*.
- `CInputCheck::VolumesOk`: não divide mais por zero quando o passo de volume é 0.
- `COperations::PastOperationTicket`: retorna 0 quando `shift` está fora do intervalo. Antes, o índice `uint` dava a volta.
- `CLimitations::OperationalTimeAccumReached`: protegida contra ponteiro de storage inválido.
- `CStrategies`:
  - O trailing stop de venda agora coloca o primeiro SL quando a posição ainda não tem SL.
  - `SetStopsForManual` compara preços normalizados e não reenvia a modificação a cada tick (erro 10025).
- `CDropdown::Close` faz um único `ChartRedraw` em vez de um por item.
- Correções anteriores:
  - Posições e ordens: iteração de trás para frente; `CloseAllPositions` fecha só o símbolo pedido.
  - `ExpertPositions`: corrigido o acesso fora do intervalo do array.
  - Botões: `CButton::ChangeState` e o construtor de cópia.
  - `IsNewCandle` compara o horário de abertura da barra.
  - `PartialClose*` fecha de fato uma parte da posição.
  - Storage verifica o handle do arquivo.
  - `ProfitReached` lê o histórico uma vez só.
  - `AccumulatedProfit` e `NumberOfTrades` corrigidos.

## [1.5.1]
- Última versão publicada no npm antes deste changelog.
