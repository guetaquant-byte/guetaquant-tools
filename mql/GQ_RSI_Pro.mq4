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

//--- global
datetime g_lastAlertTime = 0;

//---+
int OnInit()
{
   if (RSIPeriod <= 0 || Overbought <= Oversold)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   SetIndexBuffer(0, g_buyArrow, INDICATOR_DATA);
   SetIndexBuffer(1, g_sellArrow, INDICATOR_DATA);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_RSI_Pro(" + IntegerToString(RSIPeriod) + ")");
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_RSI_");
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
   if (rates_total < RSIPeriod + 5) return 0;

   int start = prev_calculated - 1;
   if (start < RSIPeriod + 2) start = RSIPeriod + 2;

   for (int i = start; i < rates_total; i++)
   {
      g_buyArrow[i] = EMPTY_VALUE;
      g_sellArrow[i] = EMPTY_VALUE;
   }

   int limit = rates_total - 1;
   for (int i = RSIPeriod + 2; i < limit; i++)
   {
      double rsi0 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, i);
      double rsi1 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, i + 1);
      double rsi2 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, i + 2);

      if (rsi0 == EMPTY_VALUE || rsi1 == EMPTY_VALUE) continue;

      //--- Oversold cross
      if (rsi1 < Oversold && rsi0 >= Oversold)
      {
         g_buyArrow[i] = low[i] - 10 * Point;
         if (AlertEnabled && time[i] != g_lastAlertTime)
         {
            Alert("GQ_RSI_Pro: Oversold cross on ", _Symbol, " ", _Period);
            g_lastAlertTime = time[i];
         }
      }

      //--- Overbought cross
      if (rsi1 > Overbought && rsi0 <= Overbought)
      {
         g_sellArrow[i] = high[i] + 10 * Point;
         if (AlertEnabled && time[i] != g_lastAlertTime)
         {
            Alert("GQ_RSI_Pro: Overbought cross on ", _Symbol, " ", _Period);
            g_lastAlertTime = time[i];
         }
      }

      //--- Bullish divergence: price makes lower low, RSI makes higher low
      if (i + 4 < rates_total)
      {
         double rsi3 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, i + 3);
         double rsi4 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, i + 4);
         double low0 = low[i];
         double low2 = low[i + 2];
         double low4 = low[i + 4];

         if (low0 < low2 && low2 < low4 && rsi0 > rsi2 && rsi2 > rsi4)
         {
            g_buyArrow[i] = low[i] - 20 * Point;
            DrawTrendline("GQ_RSI_BullDiv_", time[i], low[i], time[i + 4], low[i + 4], clrLime);
            if (AlertEnabled && time[i] != g_lastAlertTime)
            {
               Alert("GQ_RSI_Pro: Bullish divergence on ", _Symbol, " ", _Period);
               g_lastAlertTime = time[i];
            }
         }

         //--- Bearish divergence: price makes higher high, RSI makes lower high
         double high0 = high[i];
         double high2 = high[i + 2];
         double high4 = high[i + 4];
         if (high0 > high2 && high2 > high4 && rsi0 < rsi2 && rsi2 < rsi4)
         {
            g_sellArrow[i] = high[i] + 20 * Point;
            DrawTrendline("GQ_RSI_BearDiv_", time[i], high[i], time[i + 4], high[i + 4], clrRed);
            if (AlertEnabled && time[i] != g_lastAlertTime)
            {
               Alert("GQ_RSI_Pro: Bearish divergence on ", _Symbol, " ", _Period);
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
   string name = prefix + _Symbol + IntegerToString(t1);
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASHDOT);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
}
