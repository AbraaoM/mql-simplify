//+------------------------------------------------------------------+
//|                                                     DayClock.mqh |
//|  Day boundaries in trade server time. The base clock starts the  |
//|  day at a fixed server hour (0 = midnight). Derive from CDayClock |
//|  and override DayStart() when the boundary depends on the date   |
//|  (for example a reset at midnight of a time zone with daylight   |
//|  saving). No trade code.                                         |
//+------------------------------------------------------------------+
#ifndef MQL_SIMPLIFY_DAY_CLOCK_MQH
#define MQL_SIMPLIFY_DAY_CLOCK_MQH

class CDayClock {
 protected:
  int                hour;

 public:
                     CDayClock() : hour(0) {}
  virtual           ~CDayClock() {}
  void               SetHour(int newHour) { hour = (newHour < 0 || newHour > 23) ? 0 : newHour; }
  int                Hour() const { return hour; }
  //--- start (server time) of the day that contains server time t
  virtual datetime   DayStart(datetime t) const;
  //--- server hour of the boundary of the day that contains t (for display)
  virtual int        BoundaryHour(datetime t) const;
  //--- start of the current server day
  datetime           Today() const { return DayStart(TimeTradeServer()); }
};

//+------------------------------------------------------------------+
//|  Fixed hour boundary                                             |
//+------------------------------------------------------------------+
datetime CDayClock :: DayStart(datetime t) const {
  datetime shifted = t - hour * 3600;
  return shifted - (shifted % 86400) + hour * 3600;
}

//+------------------------------------------------------------------+
//|  Hour of the boundary, read from DayStart() (works for subclasses)|
//+------------------------------------------------------------------+
int CDayClock :: BoundaryHour(datetime t) const {
  MqlDateTime d;
  TimeToStruct(DayStart(t), d);
  return d.hour;
}

#endif
