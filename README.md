<p align="center">
  <img src="https://media.giphy.com/media/IHnROpQICe4kE/giphy.gif">
</p>

# MQL5Simplify
A collection of classes to simplify common mql 5 implementations to many different uses.

## How Use
Clone this repository on your Metatrader Include folder.

## Example of usage:
```c++
#include <MQL5Simplify/Graphic.mqh>

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
