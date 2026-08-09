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
input int      PivotLeft        = 5;
input int      PivotRight       = 5;
input int      MinSwingSize_Points = 50;

//--- indicator buffers
double g_bos_up[];
double g_bos_down[];

//--- global
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (PivotLeft <= 0 || PivotRight <= 0 || MinSwingSize_Points <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   SetIndexBuffer(0, g_bos_up, INDICATOR_DATA);
   SetIndexBuffer(1, g_bos_down, INDICATOR_DATA);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_Market_Structure(" + IntegerToString(PivotLeft) + "," + IntegerToString(PivotRight) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_MS_");
   Comment("");
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (rates_total < PivotLeft + PivotRight + 3) return 0;

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

   ArraySetAsSeries(g_bos_up, true);
   ArraySetAsSeries(g_bos_down, true);

   int limit = rates_total - 1;
   for (int i = 0; i < limit; i++)
   {
      g_bos_up[i] = EMPTY_VALUE;
      g_bos_down[i] = EMPTY_VALUE;
   }

   int lookback = PivotLeft + PivotRight;
   double lastSwingHigh = 0, lastSwingLow = 0;
   datetime lastSwingHighTime = 0, lastSwingLowTime = 0;
   double point = SymbolInfoDouble(g_sym, SYMBOL_POINT);

   // Arrays en serie (indice 0 = barra actual): iterar hacia ABAJO = orden cronologico,
   // acotar i+j para evitar lecturas fuera de rango (rates_total - PivotLeft - 1)
   for (int i = rates_total - PivotLeft - 1; i >= lookback; i--)
   {
      bool isSwingHigh = true;
      bool isSwingLow = true;
      double currentHigh = high[i];
      double currentLow = low[i];

      for (int j = 1; j <= PivotLeft; j++)
      {
         if (high[i + j] >= currentHigh) isSwingHigh = false;
         if (low[i + j] <= currentLow) isSwingLow = false;
      }
      for (int j = 1; j <= PivotRight; j++)
      {
         if (high[i - j] >= currentHigh) isSwingHigh = false;
         if (low[i - j] <= currentLow) isSwingLow = false;
      }

      double minSwing = MinSwingSize_Points * point;

      if (isSwingHigh)
      {
         if (lastSwingHigh > 0 && MathAbs(currentHigh - lastSwingHigh) >= minSwing)
         {
            DrawTrendline("GQ_MS_SH_", lastSwingHighTime, lastSwingHigh, time[i], currentHigh, clrRed);
         }
         lastSwingHigh = currentHigh;
         lastSwingHighTime = time[i];
      }

      if (isSwingLow)
      {
         if (lastSwingLow > 0 && MathAbs(currentLow - lastSwingLow) >= minSwing)
         {
            DrawTrendline("GQ_MS_SL_", lastSwingLowTime, lastSwingLow, time[i], currentLow, clrLime);
         }
         lastSwingLow = currentLow;
         lastSwingLowTime = time[i];
      }

      //--- Break of Structure: solo en la barra de transicion (cierre previo del otro lado)
      if (lastSwingHigh > 0 && close[i] > lastSwingHigh && close[i + 1] <= lastSwingHigh)
      {
         g_bos_up[i] = low[i] - 10 * point;
         CreateLabel("GQ_MS_BOSU_", time[i], low[i] - 15 * point, "BOS UP", clrLime);
      }
      if (lastSwingLow > 0 && close[i] < lastSwingLow && close[i + 1] >= lastSwingLow)
      {
         g_bos_down[i] = high[i] + 10 * point;
         CreateLabel("GQ_MS_BOSD_", time[i], high[i] + 15 * point, "BOS DN", clrRed);
      }
   }

   return rates_total;
}

//---+
void DrawTrendline(string prefix, datetime t1, double p1, datetime t2, double p2, color clr)
{
   string name = prefix + IntegerToString(t1);
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
}

//---+
void CreateLabel(string prefix, datetime t, double p, string text, color clr)
{
   string name = prefix + IntegerToString(t);
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
}
