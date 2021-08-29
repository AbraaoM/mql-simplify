# InputCheck

## VolumesOk

Check if volumes are ok with current symbol volume requirements.

**Parameters**

- **double** volume
- **string** messageLessThanMin = NULL
  - (default: "Volume is less than the minimum to this symbol! \n Minimum volume: %2.f \n \n Please, try again with different value.")

- **string** messageGreaterThanMax = NULL
  - (default: "Volume is greater than the maximum to this symbol! \n Maximum volume: %3.f \n \n Please, try again with different value.")

- **string** messageNotMultiple = NULL
  - (default: "Volume is not a multiple of the minimum step to this symbol!\n Minimum step: %2.f \n \n Please, try again with different value.")

**Return**

- **bool** 
  - true: All ok
  - false: Houston we have a problem, print error before return.