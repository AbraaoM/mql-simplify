//+------------------------------------------------------------------+
//|                                                     NewTypes.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

enum TRADE_TYPE {
  SELL = 0,       //Venda
  BUY = 1,        //Compra
  NOTHING = 2,    //Nenhum
  INDIFFERENT = 3 //Indiferente
};

enum BINARY_OPTIONS {
  YES = 1,    //Sim
  NO = 0,     //Não
};

enum OPERATION_OPTIONS {
  STOP_ORDER,     //Ordem Stop
  MARKET_ORDER,   //Ordem a Mercado
  BUY_ON_ASK,     //Compra no ask
  BUY_ON_BID,     //Compra no bid
  SELL_ON_ASK,    //Venda no ask
  SELL_ON_BID     //Venda no Bid
};

enum ENUM_TIME_STRING_TO_INT_TYPES {
  HHMMSS,
  HHMM,
  MMSS,
  HH,
  MM,
  SS,
};

enum PRICE_TYPE {
  OPEN,   //Abertura
  HIGH,   //Máxima
  LOW,    //Mínima
  CLOSE   //Fechamento
};

enum BUY_SELL_TYPE {
  BUY_ON_BID_SELL_ON_ASK, //Compra no BID e venda no ASK
  BUY_ON_ASK_SELL_ON_BID  //Compra no ASK e venda no BID
};

enum ENUM_OPERATIONAL_TYPE {
  TYPE_PRICE,
  TYPE_POINTS
};

enum NUMBERS {
  ONE = 1,              //1
  TWO = 2,              //2
  THREE = 3,            //3
  FOUR = 4,             //4
  FIVE = 5,             //5
  SIX = 6,              //6
  SEVEN = 7,             //7
  EIGHT = 8,            //8
  NINE = 9,             //9
  TEN = 10,             //10
  ELEVEN = 11,          //11
  TWELVE = 12,          //12
  THIRTEEN = 13,        //13
  FOURTEEN = 14,        //14
  FIFTEEN = 15,         //15
  SIXTEEN = 16,         //16
  SEVENTEEN = 17,       //17
  EIGHTEEN = 18,        //18
  NINETEEN = 19,        //19
  TWENTY = 20,          //20
  TWENTY_ONE = 21,      //21
  TWENTY_TWO = 22,      //22
  TWENTY_THREE = 23,    //23
  TWENTY_FOUR = 24,     //24
  TWENTY_FIVE = 25,     //25
  TWENTY_SIX = 26,      //26
  TWENTY_SEVEN = 27,    //27
  TWENTY_EIGHT = 28,    //28
  TWENTY_NINE = 29,     //29
  THIRTY = 30,          //30
};

