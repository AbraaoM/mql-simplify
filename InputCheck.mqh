//+------------------------------------------------------------------+
//|                                                   InputCheck.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

class CInputCheck {
 public:
  bool CInputCheck :: VolumesOk(double volume,
                                string messageLassThanMin = NULL,
                                string messageGreaterThanMax = NULL,
                                string messageNotMultiple = NULL);

};

//+------------------------------------------------------------------+
//|  Volume check                                                    |
//+------------------------------------------------------------------+
bool CInputCheck :: VolumesOk(double volume,
                              string messageLessThanMin = NULL,
                              string messageGreaterThanMax = NULL,
                              string messageNotMultiple = NULL) {
  double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

  messageLessThanMin == NULL ?
  messageLessThanMin = "Volume is less than the minimum to this symbol! \n Minimum volume: %2.f \n \n Please, try again with different value." :
                       NULL;

  messageGreaterThanMax == NULL ?
  messageGreaterThanMax = "Volume is greater than the maximum to this symbol! \n Maximum volume: %3.f \n \n Please, try again with different value." :
                          NULL;

  messageNotMultiple == NULL ?
  messageNotMultiple = "Volume is not a multiple of the minimum step to this symbol!\n Minimum step: %2.f \n \n Please, try again with different value." :
                       NULL;

  if(volume < min_volume) {
    MessageBox(StringFormat(messageLessThanMin, min_volume));
    return false;
  }

  if(volume > max_volume) {
    MessageBox(StringFormat(messageGreaterThanMax, max_volume));
    return false;
  }
  int ratio = (int)MathRound(volume / volume_step);
  if(MathAbs(ratio * volume_step - volume) > 0.0000001) {
    MessageBox(StringFormat(messageNotMultiple, volume_step));
    return false;
  }

  return true;
}
//+------------------------------------------------------------------+
