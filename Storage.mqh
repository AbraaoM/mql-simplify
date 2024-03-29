//+------------------------------------------------------------------+
//|                                                      Storage.mqh |
//|                                       Copyright 2021, Homma.tech |
//|                                           https://www.homma.tech |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Homma.tech"
#property link      "https://www.homma.tech"

class CLocalStorage {
 private:

  struct state_s {
    string           key[];
    string           value[];
  } state;
  
  string fileName_;
  int                fileHandle;
  int                KeyExists(string key);

 public:
                     CLocalStorage(string fileName);
                    ~CLocalStorage();
  void               SetState(string key, string value);
  string             GetState(string key);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLocalStorage::CLocalStorage(string fileName) {
  fileName_ = fileName;

  ResetLastError();
  fileHandle = FileOpen(fileName_ + ".csv", FILE_WRITE | FILE_READ | FILE_ANSI | FILE_CSV  | FILE_COMMON,  ';');

  int index = 0;
  while(!FileIsEnding(fileHandle)) {
    ArrayResize(state.key, ArraySize(state.key) + 1);
    ArrayResize(state.value, ArraySize(state.value) + 1);
    state.key[index] = FileReadString(fileHandle);
    state.value[index] = FileReadString(fileHandle);

    index++;
  }

  if(fileHandle == INVALID_HANDLE)
    Print(":: Não foi possível abrir o arquivo " + fileName + " (Erro: " + (string)GetLastError() + ") ::");

  FileClose(fileHandle);
  FileDelete(fileName);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLocalStorage::~CLocalStorage() {
  fileHandle = FileOpen(fileName_ + ".csv", FILE_WRITE | FILE_READ | FILE_ANSI | FILE_CSV | FILE_COMMON,  ';');
  for(int i = 0; i < ArraySize(state.key); i++) {
    FileWriteString(fileHandle, state.key[i] + ";" + state.value[i] + "\n");
  }
  FileClose(fileHandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLocalStorage :: SetState(string key, 
                               string value) {
  int index = ArraySize(state.key);
  int keyPosition = KeyExists(key);

  if(keyPosition == -1) {
    ArrayResize(state.key, ArraySize(state.key) + 1);
    ArrayResize(state.value, ArraySize(state.value) + 1);
    state.key[index] = key;
    state.value[index] = value;
  } else {
    state.value[keyPosition] = value;
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CLocalStorage :: GetState(string key) {
  int keyPosition = KeyExists(key);
  if(keyPosition != -1)
    return state.value[keyPosition];
  return "";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLocalStorage :: KeyExists(string key) {
  for(int i = 0; i < ArraySize(state.key); i++) {
    if(state.key[i] == key)
      return i;
  }
  return -1;
}

//+------------------------------------------------------------------+
