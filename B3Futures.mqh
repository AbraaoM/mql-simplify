//+------------------------------------------------------------------+
//|                                                   B3Futures.mqh  |
//|  B3 index futures (WIN / IND) calendar helpers. Pure functions:  |
//|  no terminal calls, testable.                                    |
//|  Rule (B3 contract spec, WIN and IND): expiry on the Wednesday   |
//|  closest to the 15th of the expiry month (even months). When it  |
//|  is not a trading session B3 moves it to the next session - this |
//|  holiday shift is NOT modelled here; prefer the broker's         |
//|  SYMBOL_EXPIRATION_TIME and use this only as a fallback.         |
//|  Month codes: F G H J K M N Q U V X Z = Jan..Dec.                |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_B3_FUTURES_MQH
#define MQL_SIMPLIFY_B3_FUTURES_MQH

//--- futures month letter -> 1..12, 0 when unknown
int SimplifyFuturesMonth(const ushort code) {
  string codes = "FGHJKMNQUVXZ";
  for(int i = 0; i < 12; i++)
    if(StringGetCharacter(codes, i) == code)
      return i + 1;
  return 0;
}

//--- midnight of a calendar date, 0 when invalid
datetime SimplifyMakeDate(const int year, const int month, const int day) {
  if(year < 1971 || month < 1 || month > 12 || day < 1 || day > 31)
    return 0;
  MqlDateTime t;
  ZeroMemory(t);
  t.year = year; t.mon = month; t.day = day;
  return StructToTime(t);
}

//--- Wednesday closest to the 15th of year/month (no holiday shift)
datetime SimplifyB3IndexExpiry(const int year, const int month) {
  datetime d15 = SimplifyMakeDate(year, month, 15);
  if(d15 == 0)
    return 0;
  MqlDateTime t;
  TimeToStruct(d15, t);
  int delta = ((3 - t.day_of_week) + 7) % 7;   // days forward to Wednesday
  if(delta > 3)
    delta -= 7;                                // closer going back
  return d15 + delta * 86400;
}

//--- expiry from a contract code such as "WINZ26" / "INDQ25" (root + month letter +
//    2-digit year, optional broker suffix after it). 0 for continuous series
//    (WIN$, WIN$N, WIN@...) or anything that does not parse.
datetime SimplifyB3ExpiryFromSymbol(const string symbol, const string root) {
  int rl = StringLen(root);
  if(rl < 1 || StringLen(symbol) < rl + 3 || StringSubstr(symbol, 0, rl) != root)
    return 0;
  int month = SimplifyFuturesMonth(StringGetCharacter(symbol, rl));
  ushort y1 = StringGetCharacter(symbol, rl + 1), y2 = StringGetCharacter(symbol, rl + 2);
  if(month == 0 || y1 < '0' || y1 > '9' || y2 < '0' || y2 > '9')
    return 0;
  int year = 2000 + (y1 - '0') * 10 + (y2 - '0');
  return SimplifyB3IndexExpiry(year, month);
}

//--- whole calendar days from now's date to the expiry date (0 = expiry day,
//    negative = already expired); INT_MAX when the expiry is unknown (0)
int SimplifyDaysToExpiry(const datetime now, const datetime expiry) {
  if(expiry <= 0)
    return INT_MAX;
  long a = (long)now - (long)now % 86400;
  long b = (long)expiry - (long)expiry % 86400;
  return (int)((b - a) / 86400);
}

//--- roll rule: no new position from N calendar days before expiry through the
//    expiry day (and never after it). Unknown expiry (INT_MAX) does not block.
bool SimplifyRollBlocksEntry(const int daysToExpiry, const int blockDays) {
  if(daysToExpiry == INT_MAX)
    return false;
  return daysToExpiry < 0 || daysToExpiry <= MathMax(blockDays, 0);
}

#endif
