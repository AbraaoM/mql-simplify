# Graphic

PRIMARY_COLOR C'0x28,0x2A,0x36'

SECONDARY_COLOR C'0x44,0x47,0x5A'

FONT_COLOR C'0xF8,0xF8,0xF2'

DEFAULT_FONT "Arial"

DEFAULT_FONT_SIZE 12

## CHorizontalLine

Class to create and manage a object horizontal line.

### Create

Create a line and plot on graphic.

**Parameters**

- **int** layer = 1 
- **string** name = "HLine" 
- **int** subWindow = 0 
- **double** price = 0 (default: current price bid)
- **color** lineColor = PRIMARY_COLOR 
- **ENUM_LINE_STYLE** lineStyle = STYLE_SOLID 
- **int** lineWidth = 1 
- **string** label = NULL 
- **int** fontSize = 12 

**Return**

- **bool** 
  - true: All ok
  - false: Houston we have a problem, print error before return

### ChangePrice

Move the line by changing price reference to plot the line.

**Parameters**

- **datetime** newTime
- **datetime** newPrice

### Price

Return actual price of the line.

### X

Return x coordinate of the line.

### Y

Return y coordinate of the line.

### Destroy

Destroy horizontal line object, but the class still exists. 
Don't forget delete class to avoid memory leak.


## CRetangle

Class to create and manage a retangle object.

### Create

Create a retangle object and plot on graph.

**Parameters**

- **int** layer
- **string** name
- **long** width
- **long** height
- **long** positionX
- **long** positionY
- **color** backgroundColor = PRIMARY_COLOR
- **ENUM_BORDER_TYPE** borderType = BORDER_FLAT
- **color** borderColor = PRIMARY_COLOR
- **ENUM_LINE_STYLE** borderStyle = STYLE_SOLID
- **int** borderWidth = 1
- **ENUM_BASE_CORNER** referenceCorner = CORNER_LEFT_UPPER

**Return**

- **string** - Name of object

### X

Return x coordinate of the corner define on **Create( ...referenceCorner)** retangle object. 

### Y

Return y coordinate of the corner define on **Create( ...referenceCorner)** retangle object. 

### Destroy
Destroy retangle object, but the class still exists. 
Don't forget delete class to avoid memory leak.



## CLabel

Class to create and manage a label object.

### Create

Create a label object and plot on graph.

**Parameters**

- **int** layer
- **string** name
- **string** textInput
- **long** positionX
- **long** positionY
- **string** fontName = DEFAULT_FONT
- **int** fontSize = DEFAULT_FONT_SIZE
- **color** fontColor = FONT_COLOR
- **ENUM_ANCHOR_POINT** anchor = ANCHOR_LEFT_UPPER
- **ENUM_BASE_CORNER** referenceCorner = CORNER_LEFT_UPPER 

**Return**
- **string** - Name of object

### X

Return x coordinate of the corner define on **Create( ...referenceCorner)** label object. 

### Y

Return y coordinate of the corner define on **Create( ...referenceCorner)** label object. 

### ChangeText

Change the label text.

**Parameters**

- **string** newText

### Move

Move the label by coordinates (x, y) or (time, price).

#### Overload 1

**Parameters**

- **datetime** time
- **double** price

#### Overload 2

**Parameters**

- **long** newX
- **long** newY

### Destroy

Destroy label object, but the class still exists. 
Don't forget delete class to avoid memory leak.



## CEdit

Class to create and manage a edit object.

Edit object is the method to user input data on expert by custom graphic interface.

This object have a control variable to define when object is active or not.

### Create

Variable active si defined as true.

**Parameters**

- **int** layer,
- **string** name,
- **string** textInput,
- **long** positionX,
- **long** positionY,
- **long** width,
- **long** height,
- **string** fontName = DEFAULT_FONT,
- **int** fontSize = DEFAULT_FONT_SIZE,
- **color** fontColor = FONT_COLOR,
- **color** bgColor = SECONDARY_COLOR,
- **ENUM_ALIGN_MODE** align = ALIGN_CENTER
- **ENUM_BASE_CORNER** referenceCorner = CORNER_LEFT_UPPER 

**Return**

- **string** - Name of object

### IsActive

Return value of the variable active.

### GetValue

Get the value of the edit that can be a input changed by the user. 

### SetValue

Set the value of the edit based on new text on parameters. 

**Parameters**
- **string** newText

### Destroy

Turn active state to false, but some information was mantained on class.
Destroy edit object, but the class still exists. 
Don't forget delete class to avoid memory leak.




## CButton

Construct by dependency injection, can construct a button by a ready button.

Can construct a button just changing active to false.

### Create

**Parameters**

- **int** layer,
- **string** name,
- **string** text,
- **long** width,
- **long** height,
- **long** positionX,
- **long** positionY,
- **string** fontName = DEFAULT_FONT,
- **int** fontSize = DEFAULT_FONT_SIZE,
- **color** fontColor = FONT_COLOR,
- **color** backgroundColor = SECONDARY_COLOR,
- **color** borderColor = SECONDARY_COLOR,
- **color** hoverColor = SECONDARY_COLOR,
- **ENUM_ANCHOR_POINT** anchor = ANCHOR_LEFT_UPPER

### OnClick

Detect click event on button and return true if clicked.

### State

Return the state of the button, can be true or false.

### Hover

Must be used on event hadler function OnChartEvent using CHARTEVENT_MOUSE_MOVE and passing coordinates of mouse event as parameters. 

**Parameters**
- **uint** mouseX
- **uint** mouseY

**Return**
- **bool**
  - true: mouse is over the button
  - false: mouse is out the button

### SetState

Set a new state for the button, can be equals to the current state.

**Parameters**
- **bool** newState

### ChangeState

Just change the state to the oposite.

### ChangeColor

Change the current color of the button.

**Parameters**
- **color** newBGColor
- **color** newBorderColor

### ChangeText

Change the current text of the button.

**Parameters**
- **string** text

### IsActive

Return the value of the variable active.

### Destroy

Turn active state to false, but some information was mantained on class.
Destroy button object, but the class still exists. 
Don't forget delete class to avoid memory leak.

## Dropdown
Class to control a dropdown, this class don't implements a dropdown 
controller button, just renderize an organized array of buttons 
passed as reference to contructor. 

### Constructor
Receive an array of buttons and copy this buttons to a internal array to be accessed
by other internal methods who list and hide dropdown elements. 
**Parameters**
- **CButton&** items[] 

### Open
Draw a list of buttons on chart based on array of button received on contructor.
### Close
Destroy all button on screen closing the dropdown menu.













