//+------------------------------------------------------------------+
//|                                                  Limitations.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include <Trade/Trade.mqh>

#include "Utils.mqh"
#include "NewTypes.mqh"
#include "Storage.mqh"
#include "Positions.mqh"
#include "Operations.mqh"
#include "TimeManipulation.mqh"

CPositions positionsService;
COperations operationsService;
CTimeManipulation timeManipulationService;

class CLimitations {
 private:
  CLocalStorage      *localState;

 public:

  bool CLimitations :: VolumeReached(double lim_volumeTarget,
                                     ENUM_TIMEFRAMES lim_timeframe = PERIOD_CURRENT);
  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  CLimitations :: CLimitations () {

  }

  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  CLimitations ::   ~CLimitations () { }

  //+------------------------------------------------------------------+
  //|  Time interval check function                                    |
  //+------------------------------------------------------------------+
  bool CLimitations :: InTimeInterval(string begin_, 
                                      string finish_, 
                                      bool showMessage = false) {
    if(begin_ <= TimeToString(TimeLocal(), TIME_MINUTES) &&
        TimeToString(TimeLocal(), TIME_MINUTES) < finish_)
      return true;

    if(showMessage)
      MessageBox("Out of operational time interval setted. \n\n" +
                 begin_ + " - " + finish_
                 + "\n\nPlease, change the configurations!");
    return false;
  }

  //+------------------------------------------------------------------+
  //|  Time limit check and close positions function                   |
  //+------------------------------------------------------------------+
  void CLimitations :: TimeLimit(string finish_, 
                                 int deviation) {
    if((TimeToString(TimeLocal(), TIME_MINUTES) >= finish_)) {
      positionsService.CloseAllPositions(_Symbol, deviation);
    }
  }

  //+------------------------------------------------------------------+
  //|  Days of the week operations are enable function                 |
  //+------------------------------------------------------------------+
  bool CLimitations :: IsOperationDay(int &daysOn[]) {
    MqlDateTime strTimeLocal;
    TimeToStruct(TimeLocal(), strTimeLocal);
    for(int i = 0; i < ArraySize(daysOn); i++)
      if(strTimeLocal.day_of_week == daysOn[i])
        return true;
    return false;
  }

  //+------------------------------------------------------------------+
  //|  Profit limit reached function                                   |
  //+------------------------------------------------------------------+
  bool CLimitations :: ProfitReached(double profitMax_PR, 
                                    datetime initDate_PR, 
                                    datetime finishDate_PR,
                                    string symbol_PR = NULL) {
    double acum = operationsService.AccumulatedProfit(initDate_PR, finishDate_PR, symbol_PR);
    if(operationsService.AccumulatedProfit(initDate_PR, finishDate_PR, symbol_PR) >= profitMax_PR)
      return true;
    return false;
  }

  //+------------------------------------------------------------------+
  //|  Loss limit reached function                                     |
  //+------------------------------------------------------------------+
  bool CLimitations :: LossReached(double lossMax_LR, 
                                   datetime initDate, 
                                   datetime finishDate,
                                   string symbol_LR = NULL) {
    if(operationsService.AccumulatedProfit(initDate, finishDate, symbol_LR) <= (lossMax_LR * -1))
      return true;
    return false;
  }

  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  bool CLimitations :: PercentualGainReached(double percentage, 
                                             datetime initDate, 
                                             datetime finishDate) {
    double gainLimit;

    gainLimit = AccountInfoDouble(ACCOUNT_BALANCE) * percentage;
    return ProfitReached(gainLimit, initDate, finishDate);
  }

  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  bool CLimitations :: PercentualLossReached(double percentage, 
                                             datetime initDate, 
                                             datetime finishDate) {
    double lossLimit;

    lossLimit = AccountInfoDouble(ACCOUNT_BALANCE) * percentage;
    return LossReached(lossLimit, initDate, finishDate);
  }

  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  bool CLimitations :: NumberOfTradesReached (int expectedNumber, 
                                              datetime initDate, 
                                              datetime finishDate) {
    if(operationsService.NumberOfTrades(initDate, finishDate) >= expectedNumber)
      return true;
    return false;
  }

  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  bool CLimitations :: OperationalTimeAccumReached (string limitTime, 
                                                    CLocalStorage* &external_state) {
    int timeOnOperationLimitTarget,
        sumTimeOnOperation;

    sumTimeOnOperation = (int)StringToInteger(external_state.GetState("timeOperationAcumm"));

    timeOnOperationLimitTarget = timeManipulationService.StringTimeToInt(limitTime, HHMM);

    if(sumTimeOnOperation >= timeOnOperationLimitTarget) {
      return true;
    }
    return false;
  }
};

//+------------------------------------------------------------------+
