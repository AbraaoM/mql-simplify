# MQL Simplify
A collection of classes to simplify common mql 5 implementations to many different uses.

## Instalation

### Initialize npm directory

Inside your mql project directory run the follow command:
```bash
npm init
```

### Add compile script on **package.json**

```json
  "scripts": {
    "compile": "@powershell -NoProfile -ExecutionPolicy Unrestricted -Command ./node_modules/mql-simplify/compile.ps1"
  },
```

### Install package from npm

```bash
npm install mql-simplify --save
```



## Example of usage:
```c++
#include "node_modules/mql-simplify/Graphic.mqh"

CHorizontalLine exampleLine;

int OnInit() {
  //Plot a default line on chart
  exampleLine.Create(); 
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  //Remove the exampleLine from chart 
  exampleLine.Destroy();
}
```
