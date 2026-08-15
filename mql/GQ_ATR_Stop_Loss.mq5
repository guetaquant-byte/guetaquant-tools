//+------------------------------------------------------------------+
//|                                           GQ_ATR_Stop_Loss.mq5   |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input int      ATRPeriod     = 14;
input double   ATRMultiplier = 2.0;
input int      Source        = 0; // 0=Close, 1=HL2

//--- global variables
int g_atr_handle;
string g_sym;
ENUM_TIMEFRAMES g_tf;
double g_atr_buf[];

//---+
int OnInit()
{
   if (ATRPeriod <= 0 || ATRMultiplier <= 0.0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_atr_handle = iATR(g_sym, g_tf, ATRPeriod);
   if (g_atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create iATR handle: ", GetLastError());
      return INIT_FAILED;
   }
   ArraySetAsSeries(g_atr_buf, true);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_ATR_Stop_Loss(" + IntegerToString(ATRPeriod) + "," + DoubleToString(ATRMultiplier, 1) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   ObjectDelete(0, "GQ_ATR_Long_Stop");
   ObjectDelete(0, "GQ_ATR_Short_Stop");
   Comment("");
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (rates_total < ATRPeriod + 1) return 0;

   if (g_atr_handle == INVALID_HANDLE) return 0;

   if (CopyBuffer(g_atr_handle, 0, 0, 2, g_atr_buf) < 2) return 0;
   double atr = g_atr_buf[0];
   if (atr <= 0.0) return rates_total;

   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if (CopyHigh(g_sym, g_tf, 0, 2, high) < 2) return 0;
   if (CopyLow(g_sym, g_tf, 0, 2, low) < 2) return 0;
   if (CopyClose(g_sym, g_tf, 0, 2, close) < 2) return 0;

   double longStop = high[0] - atr * ATRMultiplier;
   double shortStop = low[0] + atr * ATRMultiplier;

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
