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

   for (int i = lookback; i < rates_total - PivotLeft - 1; i++)   // bound alto[i+j] dentro del array
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

      double minSwing = MinSwingSize_Points * Point;

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

      //--- Break of Structure: fire only on the transition bar (close[i-1] on the other side)
      if (lastSwingHigh > 0 && close[i] > lastSwingHigh && close[i - 1] <= lastSwingHigh)
      {
         g_bos_up[i] = low[i] - 10 * Point;
         CreateLabel("GQ_MS_BOSU_", time[i], low[i] - 15 * Point, "BOS UP", clrLime);
      }
      if (lastSwingLow > 0 && close[i] < lastSwingLow && close[i - 1] >= lastSwingLow)
      {
         g_bos_down[i] = high[i] + 10 * Point;
         CreateLabel("GQ_MS_BOSD_", time[i], high[i] + 15 * Point, "BOS DN", clrRed);
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
