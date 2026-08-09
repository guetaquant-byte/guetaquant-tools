#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed

//--- input parameters
input int      RSIPeriod     = 14;
input int      Overbought    = 70;
input int      Oversold      = 30;
input bool     AlertEnabled  = true;

//--- indicator buffers
double g_buyArrow[];
double g_sellArrow[];

//--- handles
int g_rsi_handle;
string g_sym;
ENUM_TIMEFRAMES g_tf;
datetime g_lastAlertTime = 0;

//---+
int OnInit()
{
   if (RSIPeriod <= 0 || Overbought <= Oversold)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_rsi_handle = iRSI(g_sym, g_tf, RSIPeriod, PRICE_CLOSE);
   if (g_rsi_handle == INVALID_HANDLE)
   {
      Print("Failed to create iRSI handle: ", GetLastError());
      return INIT_FAILED;
   }
   SetIndexBuffer(0, g_buyArrow, INDICATOR_DATA);
   SetIndexBuffer(1, g_sellArrow, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_RSI_Pro(" + IntegerToString(RSIPeriod) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
   ObjectsDeleteAll(0, "GQ_RSI_");
   Comment("");
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (rates_total < RSIPeriod + 5) return 0;

   double high[], low[], close[];
   datetime time[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   if (CopyHigh(g_sym, g_tf, 0, rates_total, high) < rates_total) return 0;
   if (CopyLow(g_sym, g_tf, 0, rates_total, low) < rates_total) return 0;
   if (CopyClose(g_sym, g_tf, 0, rates_total, close) < rates_total) return 0;
   if (CopyTime(g_sym, g_tf, 0, rates_total, time) < rates_total) return 0;

   ArraySetAsSeries(g_buyArrow, true);
   ArraySetAsSeries(g_sellArrow, true);
   double rsi[];
   ArraySetAsSeries(rsi, true);

   int limit = rates_total - 1;
   for (int i = RSIPeriod + 2; i < limit; i++)
   {
      g_buyArrow[i] = EMPTY_VALUE;
      g_sellArrow[i] = EMPTY_VALUE;
   }

   for (int i = RSIPeriod + 2; i < limit; i++)
   {
      if (CopyBuffer(g_rsi_handle, 0, i, 5, rsi) < 5) continue;

      double rsi0 = rsi[0];
      double rsi1 = rsi[1];
      double rsi2 = rsi[2];
      double rsi3 = rsi[3];
      double rsi4 = rsi[4];

      //--- Oversold cross
      if (rsi1 < Oversold && rsi0 >= Oversold)
      {
         g_buyArrow[i] = low[i] - 10 * SymbolInfoDouble(g_sym, SYMBOL_POINT);
         if (AlertEnabled && time[i] != g_lastAlertTime)
         {
            Alert("GQ_RSI_Pro: Oversold cross on ", g_sym, " ", EnumToString(g_tf));
            g_lastAlertTime = time[i];
         }
      }

      //--- Overbought cross
      if (rsi1 > Overbought && rsi0 <= Overbought)
      {
         g_sellArrow[i] = high[i] + 10 * SymbolInfoDouble(g_sym, SYMBOL_POINT);
         if (AlertEnabled && time[i] != g_lastAlertTime)
         {
            Alert("GQ_RSI_Pro: Overbought cross on ", g_sym, " ", EnumToString(g_tf));
            g_lastAlertTime = time[i];
         }
      }

      //--- Bullish divergence
      if (i + 4 < rates_total)
      {
         double low0 = low[i];
         double low2 = low[i + 2];
         double low4 = low[i + 4];
         if (low0 < low2 && low2 < low4 && rsi0 > rsi2 && rsi2 > rsi4)
         {
            g_buyArrow[i] = low[i] - 20 * SymbolInfoDouble(g_sym, SYMBOL_POINT);
            DrawTrendline("GQ_RSI_BullDiv_", time[i], low[i], time[i + 4], low[i + 4], clrLime);
            if (AlertEnabled && time[i] != g_lastAlertTime)
            {
               Alert("GQ_RSI_Pro: Bullish divergence on ", g_sym, " ", EnumToString(g_tf));
               g_lastAlertTime = time[i];
            }
         }

         //--- Bearish divergence
         double high0 = high[i];
         double high2 = high[i + 2];
         double high4 = high[i + 4];
         if (high0 > high2 && high2 > high4 && rsi0 < rsi2 && rsi2 < rsi4)
         {
            g_sellArrow[i] = high[i] + 20 * SymbolInfoDouble(g_sym, SYMBOL_POINT);
            DrawTrendline("GQ_RSI_BearDiv_", time[i], high[i], time[i + 4], high[i + 4], clrRed);
            if (AlertEnabled && time[i] != g_lastAlertTime)
            {
               Alert("GQ_RSI_Pro: Bearish divergence on ", g_sym, " ", EnumToString(g_tf));
               g_lastAlertTime = time[i];
            }
         }
      }
   }
   return rates_total;
}

//---+
void DrawTrendline(string prefix, datetime t1, double p1, datetime t2, double p2, color clr)
{
   string name = prefix + g_sym + IntegerToString(t1);
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASHDOT);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
}
