#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0

//--- input parameters
input int      ATRPeriod     = 14;
input double   ATRMultiplier = 2.0;
input int      Source        = 0; // 0=Close, 1=HL2

//---+
int OnInit()
{
   if (ATRPeriod <= 0 || ATRMultiplier <= 0.0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_ATR_Stop_Loss(" + IntegerToString(ATRPeriod) + "," + DoubleToString(ATRMultiplier, 1) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectDelete(0, "GQ_ATR_Long_Stop");
   ObjectDelete(0, "GQ_ATR_Short_Stop");
   Comment("");
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (rates_total < ATRPeriod + 1) return 0;

   double atr = iATR(_Symbol, _Period, ATRPeriod, 0);
   if (atr <= 0.0) return rates_total;

   double longStop = iHigh(_Symbol,_Period,0) - atr * ATRMultiplier;
   double shortStop = iLow(_Symbol,_Period,0) + atr * ATRMultiplier;

   ObjectDelete(0, "GQ_ATR_Long_Stop");
   ObjectCreate(0, "GQ_ATR_Long_Stop", OBJ_HLINE, 0, 0, longStop);
   ObjectSetInteger(0, "GQ_ATR_Long_Stop", OBJPROP_COLOR, clrLime);
   ObjectSetInteger(0, "GQ_ATR_Long_Stop", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "GQ_ATR_Long_Stop", OBJPROP_STYLE, STYLE_SOLID);

   ObjectDelete(0, "GQ_ATR_Short_Stop");
   ObjectCreate(0, "GQ_ATR_Short_Stop", OBJ_HLINE, 0, 0, shortStop);
   ObjectSetInteger(0, "GQ_ATR_Short_Stop", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "GQ_ATR_Short_Stop", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "GQ_ATR_Short_Stop", OBJPROP_STYLE, STYLE_SOLID);

   return rates_total;
}
