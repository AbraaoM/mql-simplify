//+------------------------------------------------------------------+
//|                                             TimeManipulation.mqh |
//|                                       Copyright 2022, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"

class CTimeManipulation {
 public:
  string CTimeManipulation :: IntTimeToString (int time);

  int CTimeManipulation :: StringTimeToInt (
    string time,
    ENUM_TIME_STRING_TO_INT_TYPES selector);

  void CTimeManipulation :: TimeStringTokenizer (
    string time,
    string &tokenizedTime[]);
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
//|  String to timestamp function                                    |
//+------------------------------------------------------------------+
int CTimeManipulation :: StringTimeToInt (string time,
    ENUM_TIME_STRING_TO_INT_TYPES selector) {
  string tokenizedTime[];
  int absoluteValueTime = 0;

  TimeStringTokenizer(time, tokenizedTime);

  switch (selector) {
  case   HHMMSS:
    absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
    absoluteValueTime += (int)(StringToInteger(tokenizedTime[1]) * 60);
    absoluteValueTime += (int)StringToInteger(tokenizedTime[2]);
    break;
  case     HHMM:
    absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
    absoluteValueTime += (int)(StringToInteger(tokenizedTime[1]) * 60);
    break;
  case    MMSS:
    absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 60);
    absoluteValueTime += (int)StringToInteger(tokenizedTime[1]);
    break;
  case    HH:
    absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 3600);
    break;
  case     MM:
    absoluteValueTime = (int)(StringToInteger(tokenizedTime[0]) * 60);
    break;
  case   SS:
    absoluteValueTime = (int)StringToInteger(tokenizedTime[0]);
    break;
  }
  return absoluteValueTime;
}

//+------------------------------------------------------------------+
//|  Time tokenizer function                                         |
//+------------------------------------------------------------------+
void CTimeManipulation :: TimeStringTokenizer (
  string time,
  string &tokenizedTime[]) {

  StringSplit(time, ':', tokenizedTime);
}
//+------------------------------------------------------------------+
