# Limitations

Class CLimitations is used to centralize utilitaries to limit order emissions.

## VolumeReached



## InTimeInterval

Shows a message if current time is out of defined limits.

**Parameters**

- **string** begin_
- **string** finish_
- **bool** showMessage = false

**Return**

- **bool**
  - true: Current local time in defined limits
  - false: Current local time out of defined limits



## TimeLimit

When defined time are reached, all oppened positions will be closed.

**Parameters**
- **string** finish_
- **int** deviation



## IsOperationDay

Receive a array of days to operate and return true if current day is in the array.

**Parameters**

- **int** &daysOn[]

**Return**

- **bool**
  - true: Current local day is in the array 
  - false: Current local day in not in the array



## ProfitReached

Detects if defined profit limit is reached in defined time interval.

**Parameters**

- **double** profitMax_PR 
- **datetime** initDate_PR 
- **datetime** finishDate_PR
- **string** symbol_PR = NULL

**Return**

- **bool**
  - true: Max profit was reached
  - false: Max profit is not reached yet



## LossReached

Detects if defined loss limit is reached in defined time interval.

**Parameters**

- **double** lossMax_LR
- **datetime** initDate 
- **datetime** finishDate
- **string** symbol_LR = NULL

**Return**

- **bool**
  - true: Max loss was reached
  - false: Max loss is not reached yet



## PercentualGainReached

**Parameters**

- **double** percentage
- **datetime** initDate
- **datetime** finishDate

**Return**

- **bool**
  - true: Percentual gain was reached
  - false: Percentual gain is not reached 



## PercentualLossReached

**Parameters**

- **double** percentage
- **datetime** initDate
- **datetime** finishDate

**Return**

- **bool**
  - true: Percentual loss was reached
  - false: Percentual loss is not reached 



## NumberOfTradesReached

**Parameters**

- **int** expectedNumber 
- **datetime** initDate 
- **datetime** finishDate

**Return**

- **bool**
  - true: Number of trades was reached
  - false: Number of trades is not reached 



## OperationalTimeAccummReached

Sum time when expert is with a position open and detects if the limit time was reached.

**Parameters**

- **string** limitTime, 
- **CLocalStorage*** &external_state

**Return**

- **bool**
  - true: Sum of time on operation was reached
  - false: Sum of time on operation in not reached