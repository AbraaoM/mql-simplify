//+------------------------------------------------------------------+
//|                                                     Messages.mqh |
//|  User messages that are safe in every program type.              |
//|  Kept apart from NewTypes.mqh so that headers which only need    |
//|  the enums (Graphic, TimeManipulation, ...) do not pull a        |
//|  MessageBox call into programs that must not use it.             |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_MESSAGES_MQH
#define MQL_SIMPLIFY_MESSAGES_MQH

//+------------------------------------------------------------------+
//|  Message for the user that is safe in every program type.        |
//|  MessageBox is prohibited in indicators (it fails at run time),  |
//|  so an indicator gets Alert(); EAs and scripts keep MessageBox,  |
//|  exactly as before.                                              |
//+------------------------------------------------------------------+
int SimplifyMessageBox(string text) {
  if((ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_INDICATOR) {
    Alert(text);
    return 0;
  }
  return MessageBox(text);
}

#endif
