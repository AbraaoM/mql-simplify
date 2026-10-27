//+------------------------------------------------------------------+
//|                                                PositionMode.mqh  |
//|  Netting vs hedging position accounting. Pure functions: pass    |
//|  AccountInfoInteger(ACCOUNT_MARGIN_MODE) and the counts in.      |
//|  Netting (B3 exchange accounts, retail netting): ONE position    |
//|  per symbol; an opposite order reduces or reverses it. So a new  |
//|  entry is only safe when the symbol has no position at all (of   |
//|  any magic), and a close must be an opposite order with exactly  |
//|  the position volume.                                            |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_POSITION_MODE_MQH
#define MQL_SIMPLIFY_POSITION_MODE_MQH

//--- true for ACCOUNT_MARGIN_MODE_RETAIL_NETTING and ACCOUNT_MARGIN_MODE_EXCHANGE
bool SimplifyIsNetting(const long marginMode) {
  return marginMode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
}

//--- may a new entry be sent?
//    netting: only when the symbol has no position (ours or not) - never add to,
//             reduce or reverse an existing one by accident;
//    hedging: while this EA's positions on the symbol are below maxOwn.
bool SimplifyCanOpenEntry(const bool netting, const int symbolPositions,
                          const int ownPositions, const int maxOwn) {
  if(maxOwn < 1 || symbolPositions < 0 || ownPositions < 0)
    return false;
  if(netting)
    return symbolPositions == 0;
  return ownPositions < maxOwn;
}

//--- order that flattens a position: opposite side, exact volume.
//    positionType: POSITION_TYPE_BUY / POSITION_TYPE_SELL. Returns false when
//    the volume is not positive.
bool SimplifyCloseOrder(const long positionType, const double positionVolume,
                        ENUM_ORDER_TYPE &orderType, double &volume) {
  if(positionVolume <= 0)
    return false;
  orderType = (positionType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
  volume = positionVolume;
  return true;
}

#endif
