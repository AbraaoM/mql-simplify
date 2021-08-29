# Math

Class CMath is used to centralize math utilitaries.

## MACalculator

Calculates a moving average based on native class MovingAverages.mqh.

**Parameters**

- **double** &maBuffer_dest[] - Array with moving average calculated
- **double** &values[] - Array source to calculate moving average
- **int** period - Period of moving average
- **ENUM_MA_METHOD** ma_method = MODE_SMA 
- **int** ma_shift = 0
