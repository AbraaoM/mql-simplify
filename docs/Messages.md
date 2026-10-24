# Messages

## SimplifyMessageBox

Message for the user that is safe in every program type. `MessageBox` is prohibited in indicators, so an indicator gets `Alert()`; Expert Advisors and scripts keep `MessageBox`.

Used by `InputCheck` and `Limitations`. It lives in its own file so that headers that only need the enums of `NewTypes.mqh` do not pull a `MessageBox` call.

**Parameters**

- **string** text

**Return**

- **int** - MessageBox result (0 in indicators)
