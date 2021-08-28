//+------------------------------------------------------------------+
//|                                                         Math.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include <MovingAverages.mqh>
#include "NewTypes.mqh"

class CMath {
 private:

 public:
  CMath();
  ~CMath();

  void MACalculator(double &maBuffer_dest[],
                    double &values[],
                    int period,
                    ENUM_MA_METHOD ma_method = MODE_SMA,
                    int ma_shift = 0);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMath::CMath() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMath::~CMath() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMath :: MACalculator(double &maBuffer_dest[],
                           double &values[],
                           int period,
                           ENUM_MA_METHOD ma_method = MODE_SMA,
                           int ma_shift = 0) {
  int retorno;
  switch (ma_method) {
  case MODE_SMA:
    SimpleMAOnBuffer(ArraySize(values), 0, 0, period, values, maBuffer_dest);
    break;
  case MODE_EMA:
    ExponentialMAOnBuffer(ArraySize(values), 0, 0, period, values, maBuffer_dest);
    break;
  case MODE_SMMA:
    SmoothedMAOnBuffer(ArraySize(values), 0, 0, period, values, maBuffer_dest);
    break;
  case MODE_LWMA:
    LinearWeightedMAOnBuffer(ArraySize(values), 0, 0, period, values, maBuffer_dest, retorno);
    break;
  }
}
//+------------------------------------------------------------------+
