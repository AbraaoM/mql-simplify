//+------------------------------------------------------------------+
//|                                                    indicador.mq5 |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"
#property version   "1.00"
#property indicator_chart_window

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plotar iMA
#property indicator_label1  "iMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+------------------------------------------------------------------+
//| Enumerador dos métodos de criação do manipulador                 |
//+------------------------------------------------------------------+
enum Creation {
  Call_iMA,               // usar iMA
  Call_IndicatorCreate    // usar IndicatorCreate
};
//--- parâmetros de entrada
input Creation             type = Call_iMA;              // tipo de função
input int                  ma_period = 10;               // período da média móvel
input int                  ma_shift = 0;                 // deslocamento
input ENUM_MA_METHOD       ma_method = MODE_SMA;         // tipo de suavização
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;  // tipo de preço
input string               symbol = " ";                 // símbolo
input ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe
input color                ma_color = clrBlue;           // cor da linha
//--- buffer do indicador
double         iMABuffer[];
//--- variável para armazenar o manipulador do indicator iMA
int    handle;
//--- variável para armazenamento
string name = symbol;
//--- nome do indicador num gráfico
string short_name;
//--- manteremos o número de valores no indicador Moving Average
int    bars_calculated = 0;
//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {
//--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iMABuffer, INDICATOR_DATA);
  
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ma_color);
//--- definir deslocamento
  PlotIndexSetInteger(0, PLOT_SHIFT, ma_shift);
//--- determinar o símbolo do indicador, é desenhado para
  name = symbol;
//--- excluir os espaços à direita e à esquerda
  StringTrimRight(name);
  StringTrimLeft(name);
//--- se resulta em comprimento zero da string do 'name'
  if(StringLen(name) == 0) {
    //--- tomar o símbolo do gráfico, o indicador está anexado para
    name = _Symbol;
  }
//--- criar manipulador do indicador
  if(type == Call_iMA)
    handle = iMA(name, period, ma_period, ma_shift, ma_method, applied_price);
  else {
    //--- preencher a estrutura com os parâmetros do indicador
    MqlParam pars[4];
    //--- período
    pars[0].type = TYPE_INT;
    pars[0].integer_value = ma_period;
    //--- deslocamento
    pars[1].type = TYPE_INT;
    pars[1].integer_value = ma_shift;
    //--- tipo de suavização
    pars[2].type = TYPE_INT;
    pars[2].integer_value = ma_method;
    //--- tipo de preço
    pars[3].type = TYPE_INT;
    pars[3].integer_value = applied_price;
    handle = IndicatorCreate(name, period, IND_MA, 4, pars);
  }
//--- se o manipulador não é criado
  if(handle == INVALID_HANDLE) {
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat("Falha ao criar o manipulador do indicador iMA para o símbolo %s/%s, código de erro %d",
                name,
                EnumToString(period),
                GetLastError());
    //--- o indicador é interrompido precocemente
    return(INIT_FAILED);
  }
//--- mostra que o símbolo/prazo do indicador Moving Average é calculado para
  short_name = StringFormat("iMA(%s/%s, %d, %d, %s, %s)", name, EnumToString(period),
                            ma_period, ma_shift, EnumToString(ma_method), EnumToString(applied_price));
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Função de iteração do indicador customizado                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//--- número de valores copiados a partir do indicador iMA
  int values_to_copy;
//--- determinar o número de valores calculados no indicador
  int calculated = BarsCalculated(handle);
  if(calculated <= 0) {
    PrintFormat("BarsCalculated() retornando %d, código de erro %d", calculated, GetLastError());
    return(0);
  }
//--- se for o princípio do cálculo do indicador, ou se o número de valores é modificado no indicador iMA
//--- ou se é necessário cálculo do indicador para duas ou mais barras (isso significa que algo mudou no histórico do preço)
  if(prev_calculated == 0 || calculated != bars_calculated || rates_total > prev_calculated + 1) {
    //--- se o array iMABuffer é maior do que o número de valores no indicador iMA para o símbolo/período, então não copiamos tudo
    //--- caso contrário, copiamos menor do que o tamanho dos buffers do indicador
    if(calculated > rates_total) values_to_copy = rates_total;
    else                       values_to_copy = calculated;
  } else {
    //--- isso significa que não é a primeira vez do cálculo do indicador, é desde a última chamada de OnCalculate())
    //--- para o cálculo não mais do que uma barra é adicionada
    values_to_copy = (rates_total - prev_calculated) + 1;
  }
//--- preencher o array iMABuffer com valores do indicador Adaptive Moving Average
//--- se FillArrayFromBuffer retorna falso, significa que a informação não está pronta ainda, sair da operação
  if(!FillArrayFromBuffer(iMABuffer, ma_shift, handle, values_to_copy)) return(0);
//--- formar a mensagem
  string comm = StringFormat("%s ==>  Valor atualizado no indicador %s: %d",
                             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                             short_name,
                             values_to_copy);
//--- exibir a mensagem de serviço no gráfico
  Comment(comm);
//--- memorizar o número de valores no indicador Moving Average
  bars_calculated = calculated;
//--- retorna o valor prev_calculated para a próxima chamada
  return(rates_total);
}
//+------------------------------------------------------------------+
//| Preencher buffers do indicador a partir do indicador MA          |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // buffer do indicator para valores do Moving Average
                         int shift,         // deslocamento
                         int ind_handle,     // manipulador do indicador iMA
                         int amount          // número de valores copiados
                        ) {
//--- redefinir o código de erro
  ResetLastError();
//--- preencher uma parte do array iMABuffer com valores do buffer do indicador que tem índice 0 (zero)
  if(CopyBuffer(ind_handle, 0, -shift, amount, values) < 0) {
    //--- Se a cópia falhar, informe o código de erro
    PrintFormat("Falha ao copiar dados do indicador iMA, código de erro %d", GetLastError());
    //--- parar com resultado zero - significa que indicador é considerado como não calculado
    return(false);
  }
//--- está tudo bem
  return(true);
}
//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  if(handle != INVALID_HANDLE)
    IndicatorRelease(handle);
//--- limpar o gráfico após excluir o indicador
  Comment("");
}     
//+------------------------------------------------------------------+
