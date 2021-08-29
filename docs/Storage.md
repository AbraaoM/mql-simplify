# Storage

Class to manage state between many archives, classes, etc.

## CLocalStorage

Store information local, while metatrader is open the information will be saved on class, when metatrader is closed, the information will be saved on csv file.

Use a key/value structure.

### Contructor

**Parameters**

- **string** filename - csv file that will be the database for the service, if file don't exists, falie will be created, else file will be open

### Destructor

Write information on csv file.

### SetState

**Parameters**

- **string** key
- **string** value

### GetState

**Parameters**

- **string** key

**Return**

- **string** - Value on key position

### KeyExists

**Parameters**

- **string** key

**Return**

- **int** - Position in the array of states





