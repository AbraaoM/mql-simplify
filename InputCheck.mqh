//+------------------------------------------------------------------+
//|                                                   InputCheck.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"
#include "Messages.mqh"

class CInputCheck {
 public:
  bool CInputCheck :: VolumesOk(double volume,
                                string messageLessThanMin = NULL,
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
  messageLessThanMin = "Volume is less than the minimum to this symbol! \n Minimum volume: %.2f \n \n Please, try again with different value." :
                       NULL;

  messageGreaterThanMax == NULL ?
  messageGreaterThanMax = "Volume is greater than the maximum to this symbol! \n Maximum volume: %.2f \n \n Please, try again with different value." :
                          NULL;

  messageNotMultiple == NULL ?
  messageNotMultiple = "Volume is not a multiple of the minimum step to this symbol!\n Minimum step: %.2f \n \n Please, try again with different value." :
                       NULL;

  if(volume < min_volume) {
    SimplifyMessageBox(StringFormat(messageLessThanMin, min_volume));
    return false;
  }

  if(volume > max_volume) {
    SimplifyMessageBox(StringFormat(messageGreaterThanMax, max_volume));
    return false;
  }
  int ratio = (volume_step > 0) ? (int)MathRound(volume / volume_step) : 0;
  if(volume_step > 0 && MathAbs(ratio * volume_step - volume) > 0.0000001) {
    SimplifyMessageBox(StringFormat(messageNotMultiple, volume_step));
    return false;
  }

  return true;
}
//+------------------------------------------------------------------+
