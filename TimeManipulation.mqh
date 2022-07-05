//+------------------------------------------------------------------+
//|                                             TimeManipulation.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"

class CTimeManipulation {
  string CTimeManipulation :: IntTimeToString (int time);
};

//+------------------------------------------------------------------+
//|  Timestamp to string function                                    |
//+------------------------------------------------------------------+
string CTimeManipulation :: IntTimeToString (int time) {
  string timeOnString;
  int temp;

  temp = time / 3600;
  if(temp < 10)
    StringAdd(timeOnString, ("0" + IntegerToString(temp) + ":"));
  else
    StringAdd(timeOnString, (IntegerToString(temp) + ":"));
  time -= temp * 3600;

  temp = time / 60;
  if(temp < 10)
    StringAdd(timeOnString, ("0" + IntegerToString(temp) + ":"));
  else
    StringAdd(timeOnString, (IntegerToString(temp) + ":"));
  time -= temp * 60;

  if(time < 10)
    StringAdd(timeOnString, ("0" + IntegerToString(time)));
  else
    StringAdd(timeOnString, IntegerToString(time));

  return timeOnString;
}
//+------------------------------------------------------------------+
