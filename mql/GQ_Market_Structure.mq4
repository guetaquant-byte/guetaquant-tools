//+------------------------------------------------------------------+
//|                                           GQ_Market_Structure.mq4 |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
#property strict
#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
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

//---+
int OnInit()
{
   if (PivotLeft <= 0 || PivotRight <= 0 || MinSwingSize_Points <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   SetIndexBuffer(0, g_bos_up);
   SetIndexBuffer(1, g_bos_down);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_Market_Structure(" + IntegerToString(PivotLeft) + "," + IntegerToString(PivotRight) + ")");
   SetIndexArrow(0, 241);
   SetIndexArrow(1, 242);
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
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (rates_total < PivotLeft + PivotRight + 3) return 0;

   int start = prev_calculated - 1;
   if (start < PivotLeft + PivotRight + 2) start = PivotLeft + PivotRight + 2;
   if (start >= rates_total) start = rates_total - 1;

   for (int i = start; i < rates_total; i++)
   {
      g_bos_up[i] = EMPTY_VALUE;
      g_bos_down[i] = EMPTY_VALUE;
   }

   int lookback = PivotLeft + PivotRight;
   double lastSwingHigh = 0, lastSwingLow = 0;
   datetime lastSwingHighTime = 0, lastSwingLowTime = 0;

   for (int m = lookback; m < rates_total - PivotLeft - 1; m++)   // bound alto[m+j] dentro del array
   {
      bool isSwingHigh = true;
      bool isSwingLow = true;
      double currentHigh = high[m];
      double currentLow = low[m];

      for (int j1 = 1; j1 <= PivotLeft; j1++)
      {
         if (high[m + j1] >= currentHigh) isSwingHigh = false;
         if (low[m + j1] <= currentLow) isSwingLow = false;
      }
      for (int j2 = 1; j2 <= PivotRight; j2++)
      {
         if (high[m - j2] >= currentHigh) isSwingHigh = false;
         if (low[m - j2] <= currentLow) isSwingLow = false;
      }

      double minSwing = MinSwingSize_Points * Point;

      if (isSwingHigh)
      {
         if (lastSwingHigh > 0 && MathAbs(currentHigh - lastSwingHigh) >= minSwing)
         {
            DrawTrendline("GQ_MS_SH_", lastSwingHighTime, lastSwingHigh, time[m], currentHigh, clrRed);
         }
         lastSwingHigh = currentHigh;
         lastSwingHighTime = time[m];
      }

      if (isSwingLow)
      {
         if (lastSwingLow > 0 && MathAbs(currentLow - lastSwingLow) >= minSwing)
         {
            DrawTrendline("GQ_MS_SL_", lastSwingLowTime, lastSwingLow, time[m], currentLow, clrLime);
         }
         lastSwingLow = currentLow;
         lastSwingLowTime = time[m];
      }

      //--- Break of Structure: fire only on the transition bar (close[m-1] on the other side)
      if (lastSwingHigh > 0 && close[m] > lastSwingHigh && close[m - 1] <= lastSwingHigh)
      {
         g_bos_up[m] = low[m] - 10 * Point;
         CreateLabel("GQ_MS_BOSU_", time[m], low[m] - 15 * Point, "BOS UP", clrLime);
      }
      if (lastSwingLow > 0 && close[m] < lastSwingLow && close[m - 1] >= lastSwingLow)
      {
         g_bos_down[m] = high[m] + 10 * Point;
         CreateLabel("GQ_MS_BOSD_", time[m], high[m] + 15 * Point, "BOS DN", clrRed);
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
