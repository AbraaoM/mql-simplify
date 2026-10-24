//+------------------------------------------------------------------+
//|                                                      Graphic.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

#include "NewTypes.mqh"

#define PRIMARY_COLOR C'0x28,0x2A,0x36'
#define SECONDARY_COLOR C'0x44,0x47,0x5A'
#define FONT_COLOR C'0xF8,0xF8,0xF2'
#define DEFAULT_FONT "Arial"
#define DEFAULT_FONT_SIZE 12

class CHorizontalLine {
 private:
  string             horizontalLineID;
  int                x, y;
 public:
  bool CHorizontalLine :: Create(int layer = 1,
                                 string name = "HLine",
                                 int subWindow = 0,
                                 double price = 0,
                                 color lineColor = PRIMARY_COLOR,
                                 ENUM_LINE_STYLE lineStyle = STYLE_SOLID,
                                 int lineWidth = 1,
                                 string label = NULL,
                                 int fontSize = 12) {
    horizontalLineID = IntegerToString(layer) + "_" + name;
    if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    ResetLastError();
    if(!ObjectCreate(0,
                     horizontalLineID,
                     OBJ_HLINE,
                     subWindow,
                     0,
                     price)) {
      Print(__FUNCTION__,
            ": falha ao criar um linha horizontal! Código de erro = ",
            GetLastError());
      return(false);
    }
    ObjectSetInteger(0, horizontalLineID, OBJPROP_COLOR, lineColor);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_STYLE, lineStyle);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_WIDTH, lineWidth);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_BACK, false);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_SELECTED, true);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_ZORDER, 1);
    ObjectSetString(0, horizontalLineID, OBJPROP_TEXT, label);
    ObjectSetInteger(0, horizontalLineID, OBJPROP_FONTSIZE, fontSize);

    ChartTimePriceToXY(0, 0, TimeCurrent(), price, x, y);
    return(true);
  }

  void CHorizontalLine :: ChangePrice(datetime newTime,
                                      double newPrice) {
    ObjectMove(0, horizontalLineID, 0, newTime, newPrice);
  }

  double CHorizontalLine :: Price() {
    return ObjectGetDouble(0, horizontalLineID, OBJPROP_PRICE);
  }

  int CHorizontalLine :: X() {
    ChartTimePriceToXY(0, 0, TimeCurrent(), Price(), x, y);
    return x;
  }

  int CHorizontalLine :: Y() {
    ChartTimePriceToXY(0, 0, TimeCurrent(), Price(), x, y);
    return y;
  }

  void CHorizontalLine :: Destroy() {
    ObjectDelete(0, horizontalLineID);
  }
};

class CRetangle {
 private:
  string             retangleName;
  long x,
       y;
 public:
  string CRetangle :: Create(int layer,
                             string name,
                             long width,
                             long height,
                             long positionX,
                             long positionY,
                             color backgroundColor = PRIMARY_COLOR,
                             ENUM_BORDER_TYPE borderType = BORDER_FLAT,
                             color borderColor = PRIMARY_COLOR,
                             ENUM_LINE_STYLE borderStyle = STYLE_SOLID,
                             int borderWidth = 1,
                             ENUM_BASE_CORNER referenceCorner = CORNER_LEFT_UPPER) {
    x = positionX;
    y = positionY;
    retangleName = IntegerToString(layer) + "_" + name;

    ObjectCreate(0,
                 retangleName,
                 OBJ_RECTANGLE_LABEL,
                 0,
                 0,
                 0);
    ObjectSetInteger(0, retangleName, OBJPROP_XDISTANCE, positionX);
    ObjectSetInteger(0, retangleName, OBJPROP_YDISTANCE, positionY);

    ObjectSetInteger(0, retangleName, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, retangleName, OBJPROP_YSIZE, height);

    ObjectSetInteger(0, retangleName, OBJPROP_BGCOLOR, backgroundColor);

    ObjectSetInteger(0, retangleName, OBJPROP_BORDER_TYPE, borderType);

    ObjectSetInteger(0, retangleName, OBJPROP_CORNER, referenceCorner);

    ObjectSetInteger(0, retangleName, OBJPROP_COLOR, borderColor);

    ObjectSetInteger(0, retangleName, OBJPROP_STYLE, borderStyle);

    ObjectSetInteger(0, retangleName, OBJPROP_WIDTH, borderWidth);

    ObjectSetInteger(0, retangleName, OBJPROP_BACK, false);
    ObjectSetInteger(0, retangleName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, retangleName, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, retangleName, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, retangleName, OBJPROP_ZORDER, 100);

    return retangleName;
  }
  long CRetangle ::  X() {
    return x;
  }
  long CRetangle ::  Y() {
    return y;
  }
  void CRetangle ::  Destroy() {
    ObjectDelete(0, retangleName);
  }
};

class CLabel {
 private:
  string             labelName;
 public:
  string CLabel ::   Create(int layer,
                            string name,
                            string textInput,
                            long positionX,
                            long positionY,
                            string fontName = DEFAULT_FONT,
                            int fontSize = DEFAULT_FONT_SIZE,
                            color fontColor = FONT_COLOR,
                            ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER,
                            ENUM_BASE_CORNER referenceCorner = CORNER_LEFT_UPPER) {
    labelName = IntegerToString(layer) + "_" + name;
    ObjectCreate(0,
                 labelName,
                 OBJ_LABEL,
                 0,
                 0,
                 0);
    //--- definir coordenadas da etiqueta
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, positionX);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, positionY);
    //--- determinar o canto do gráfico onde as coordenadas do ponto são definidas
    ObjectSetInteger(0, labelName, OBJPROP_CORNER, referenceCorner);
    //--- definir o texto
    ObjectSetString(0, labelName, OBJPROP_TEXT, textInput);
    //--- definir o texto fonte
    ObjectSetString(0, labelName, OBJPROP_FONT, fontName);
    //--- definir tamanho da fonte
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, fontSize);
    //--- definir o ângulo de inclinação do texto
    ObjectSetDouble(0, labelName, OBJPROP_ANGLE, 0.0);
    //--- tipo de definição de ancoragem
    ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, anchor);
    //--- definir cor
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, fontColor);
    //--- exibir em primeiro plano (false) ou fundo (true)
    ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
    //--- Habilitar (true) ou desabilitar (false) o modo de movimento da etiqueta pelo mouse
    ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, labelName, OBJPROP_SELECTED, false);
    //--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
    ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, false);
    //--- definir a prioridade para receber o evento com um clique do mouse no gráfico
    ObjectSetInteger(0, labelName, OBJPROP_ZORDER, 2);

    return labelName;
  }

  long CLabel ::     X() {
    return ObjectGetInteger(0, labelName, OBJPROP_XDISTANCE);
  }

  long CLabel ::     Y() {
    return ObjectGetInteger(0, labelName, OBJPROP_YDISTANCE);
  }

  void CLabel ::     ChangeText(string newText) {
    ObjectSetString(0, labelName, OBJPROP_TEXT, newText);
  }
  void CLabel ::     Move(datetime time,
                          double price) {
    ObjectMove(0, labelName, 0, time, price);
  }

  void CLabel ::     Move(long newX,
                          long newY) {
    if(newX != X())
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, newX);
    if(newY != Y())
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, newY);
  }

  void CLabel ::     Destroy() {
    ObjectDelete(0, labelName);
  }
};

class CEdit {
 private:
  string             editName;
  bool               active;
 public:
  CEdit ::           CEdit() {
    active = false;
  }

  string CEdit ::    Create(int layer,
                            string name,
                            string textInput,
                            long positionX,
                            long positionY,
                            long width,
                            long height,
                            string fontName = DEFAULT_FONT,
                            int fontSize = DEFAULT_FONT_SIZE,
                            color fontColor = FONT_COLOR,
                            color bgColor = SECONDARY_COLOR,
                            ENUM_ALIGN_MODE align = ALIGN_CENTER,
                            ENUM_BASE_CORNER referenceCorner = CORNER_LEFT_UPPER) {
    active = true;
    editName = IntegerToString(layer) + "_" + name;
    ObjectCreate(0,
                 editName,
                 OBJ_EDIT,
                 0,
                 0,
                 0);
    //--- definir coordenadas da etiqueta
    ObjectSetInteger(0, editName, OBJPROP_XDISTANCE, positionX);
    ObjectSetInteger(0, editName, OBJPROP_YDISTANCE, positionY);
    //--- definir tamanho do objeto
    ObjectSetInteger(0, editName, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, editName, OBJPROP_YSIZE, height);
    //--- definir o tipo de alinhamento do texto no objeto
    ObjectSetInteger(0, editName, OBJPROP_ALIGN, align);
    //--- determinar o canto do gráfico onde as coordenadas do ponto são definidas
    ObjectSetInteger(0, editName, OBJPROP_CORNER, referenceCorner);
    //--- definir o texto
    ObjectSetString(0, editName, OBJPROP_TEXT, textInput);
    //--- definir o texto fonte
    ObjectSetString(0, editName, OBJPROP_FONT, fontName);
    //--- definir tamanho da fonte
    ObjectSetInteger(0, editName, OBJPROP_FONTSIZE, fontSize);
    //--- definir o ângulo de inclinação do texto
    ObjectSetDouble(0, editName, OBJPROP_ANGLE, 0.0);
    //--- definir cor
    ObjectSetInteger(0, editName, OBJPROP_COLOR, fontColor);
    //--- definir a cor de fundo
    ObjectSetInteger(0, editName, OBJPROP_BGCOLOR, bgColor);
    //--- exibir em primeiro plano (false) ou fundo (true)
    ObjectSetInteger(0, editName, OBJPROP_BACK, false);
    //--- Habilitar (true) ou desabilitar (false) o modo de movimento da etiqueta pelo mouse
    ObjectSetInteger(0, editName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, editName, OBJPROP_SELECTED, false);
    //--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
    ObjectSetInteger(0, editName, OBJPROP_HIDDEN, false);
    //--- definir a prioridade para receber o evento com um clique do mouse no gráfico
    ObjectSetInteger(0, editName, OBJPROP_ZORDER, 10);

    return editName;
  }


  bool CEdit ::      IsActive() {
    return active;
  }

  string CEdit ::    GetValue() {
    return ObjectGetString(0, editName, OBJPROP_TEXT);
  }

  void CEdit ::      SetValue(string newText) {
    ObjectSetString(0, editName, OBJPROP_TEXT, newText);
  }

  void CEdit ::      Destroy() {
    active = false;
    ObjectDelete(0, editName);
  }

};

class CButton {
 public:
  ulong              xi, yi, xf, yf;
  int                buttonLayer;
  string             buttonName;
  bool               active;
  string             buttonText;
  long               buttonWidth;
  long               buttonHeight;
  long               buttonPositionX;
  long               buttonPositionY;
  string             buttonFontName;
  int                buttonFontSize;
  color              buttonFontColor;
  color              buttonBackgroundColor;
  color              buttonBorderColor;
  color              buttonHoverColor;
  ENUM_BASE_CORNER   buttonReferenceCorner;
  CButton ::         CButton() {}
  CButton ::         CButton(int layer,
                             string name,
                             string text,
                             long width,
                             long height,
                             long positionX,
                             long positionY,
                             string fontName = DEFAULT_FONT,
                             int fontSize = DEFAULT_FONT_SIZE,
                             color fontColor = FONT_COLOR,
                             color backgroundColor = SECONDARY_COLOR,
                             color borderColor = SECONDARY_COLOR,
                             color hoverColor = SECONDARY_COLOR,
                             ENUM_BASE_CORNER referenceCorner = CORNER_LEFT_UPPER) {
    active = false;
    buttonName = IntegerToString(layer) + "_" + name;
    buttonLayer = layer;
    buttonText = text;
    buttonWidth = width;
    buttonHeight = height;
    buttonPositionX = positionX;
    buttonPositionY = positionY;
    buttonFontName = fontName;
    buttonFontSize = fontSize;
    buttonFontColor = fontColor;
    buttonBackgroundColor = backgroundColor;
    buttonBorderColor = borderColor;
    buttonHoverColor = hoverColor;
    buttonReferenceCorner = referenceCorner;
  }
  CButton ::         CButton(const CButton &other) {
    xi = other.xi; yi = other.yi; xf = other.xf; yf = other.yf;
    buttonLayer = other.buttonLayer;
    buttonName = other.buttonName;
    active = other.active;
    buttonText = other.buttonText;
    buttonWidth = other.buttonWidth;
    buttonHeight = other.buttonHeight;
    buttonPositionX = other.buttonPositionX;
    buttonPositionY = other.buttonPositionY;
    buttonFontName = other.buttonFontName;
    buttonFontSize = other.buttonFontSize;
    buttonFontColor = other.buttonFontColor;
    buttonBackgroundColor = other.buttonBackgroundColor;
    buttonBorderColor = other.buttonBorderColor;
    buttonHoverColor = other.buttonHoverColor;
    buttonReferenceCorner = other.buttonReferenceCorner;
  }

  string CButton ::  Draw(long positionX = NULL, long positionY = NULL) {
    buttonPositionX = positionX == NULL ? buttonPositionX : positionX;
    buttonPositionY = positionY == NULL ? buttonPositionY : positionY;

    active = true;
    ObjectCreate(0,
                 buttonName,
                 OBJ_BUTTON,
                 0,
                 0,
                 0);
    //--- definir coordenadas do botão
    ObjectSetInteger(0, buttonName, OBJPROP_XDISTANCE, buttonPositionX);
    ObjectSetInteger(0, buttonName, OBJPROP_YDISTANCE, buttonPositionY);
    xi = buttonPositionX;
    yi = buttonPositionY;

    //--- definir tamanho do botão
    ObjectSetInteger(0, buttonName, OBJPROP_XSIZE, buttonWidth);
    ObjectSetInteger(0, buttonName, OBJPROP_YSIZE, buttonHeight);
    xf = xi + buttonWidth;
    yf = yi + buttonHeight;

    //--- determinar o canto do gráfico onde as coordenadas do ponto são definidas
    ObjectSetInteger(0, buttonName, OBJPROP_CORNER, buttonReferenceCorner);
    //--- definir o texto
    ObjectSetString(0, buttonName, OBJPROP_TEXT, buttonText);
    //--- definir o texto fonte
    ObjectSetString(0, buttonName, OBJPROP_FONT, buttonFontName);
    //--- definir tamanho da fonte
    ObjectSetInteger(0, buttonName, OBJPROP_FONTSIZE, buttonFontSize);
    //--- definir a cor do texto
    ObjectSetInteger(0, buttonName, OBJPROP_COLOR, buttonFontColor);
    //--- definir a cor de fundo
    ObjectSetInteger(0, buttonName, OBJPROP_BGCOLOR, buttonBackgroundColor);
    //--- definir a cor da borda
    ObjectSetInteger(0, buttonName, OBJPROP_BORDER_COLOR, buttonBorderColor);
    //--- exibir em primeiro plano (false) ou fundo (true)
    ObjectSetInteger(0, buttonName, OBJPROP_BACK, false);
    //--- set button state
    ObjectSetInteger(0, buttonName, OBJPROP_STATE, false);
    //--- habilitar (true) ou desabilitar (false) o modo do movimento do botão com o mouse
    ObjectSetInteger(0, buttonName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, buttonName, OBJPROP_SELECTED, false);
    //--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
    ObjectSetInteger(0, buttonName, OBJPROP_HIDDEN, false);
    //--- definir a prioridade para receber o evento com um clique do mouse no gráfico
    ObjectSetInteger(0, buttonName, OBJPROP_ZORDER, 10);

    return buttonName;
  }
  bool CButton ::    OnClick() {
    if((bool)ObjectGetInteger(0,
                              buttonName,
                              OBJPROP_STATE)) {
      ObjectSetInteger(0,
                       buttonName,
                       OBJPROP_STATE,
                       false);
      return true;
    }
    return false;
  }
  bool CButton ::    State() {
    return (bool)ObjectGetInteger(0,
                                  buttonName,
                                  OBJPROP_STATE);
  }

  bool CButton ::    Hover(uint mouseX,
                           uint mouseY) {
    if((mouseX > xi && mouseX < xf) &&
        (mouseY > yi && mouseY < yf)) {
      ChangeColor(buttonHoverColor, buttonHoverColor);
      return true;
    }
    ChangeColor(buttonBackgroundColor, buttonBorderColor);
    return false;
  }

  void CButton ::    SetState(bool newState) {
    ObjectSetInteger(0,
                     buttonName,
                     OBJPROP_STATE,
                     newState);
  }
  void CButton ::    ChangeState() {
    if(State() == true)
      SetState(false);
    else
      SetState(true);
  }

  void CButton       ::ChangeColor(color newBGColor,
                                   color newBorderColor) {
    ObjectSetInteger(0, buttonName, OBJPROP_BGCOLOR, newBGColor);
    ObjectSetInteger(0, buttonName, OBJPROP_BORDER_COLOR, newBorderColor);
  }
  void CButton ::    ChangeText(string text) {
    ObjectSetString(0, buttonName, OBJPROP_TEXT, text);
  }



  string CButton ::  GetText() {
    return buttonText;
  }

  bool CButton ::    IsActive() {
    return active;
  }

  void CButton ::    Destroy() {
    active = false;
    ObjectDelete(0, buttonName);
  }
};

class CDropdown {
 public:
  CButton            elements[];

  CDropdown ::       CDropdown();
  CDropdown ::       CDropdown(CButton& items[]);
  CDropdown ::       ~CDropdown();
  void CDropdown ::  Open();
  void CDropdown ::  Close();
  void CDropdown ::  Destroy();
};

//+------------------------------------------------------------------+
//|  Constructors                                                    |
//+------------------------------------------------------------------+
CDropdown :: CDropdown() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDropdown :: CDropdown(CButton& items[]) {
  ArrayResize(elements, ArraySize(items));
  for(int i = 0; i < ArraySize(items); i++) {
    elements[i] = items[i];
  }
}

//+------------------------------------------------------------------+
//|  Destructor: chart objects are removed only by Close()/Destroy() |
//+------------------------------------------------------------------+
CDropdown :: ~CDropdown() {}

//+------------------------------------------------------------------+
//|  Dropdown open function                                          |
//+------------------------------------------------------------------+
void CDropdown :: Open() {
  for(int i = 0; i < ArraySize(elements); i++) {
    elements[i].Draw(elements[i].buttonPositionX,
                     elements[i].buttonPositionY + i*elements[i].buttonHeight);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDropdown ::  Close() {
  for(int i = 0; i < ArraySize(elements); i++) {
    elements[i].buttonPositionY = elements[i].buttonPositionY - i*elements[i].buttonHeight;
    elements[i].Destroy();
  }
  //--- one redraw after the loop (it was one per item)
  ChartRedraw();
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  Dropdown destroy function: removes all items from the chart     |
//+------------------------------------------------------------------+
void CDropdown ::  Destroy() {
  for(int i = 0; i < ArraySize(elements); i++)
    elements[i].Destroy();
  ArrayFree(elements);
  ChartRedraw();
}
//+------------------------------------------------------------------+
