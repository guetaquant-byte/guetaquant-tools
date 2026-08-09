#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0

//--- input parameters
input int      PivotLookback       = 10;
input int      ClusterDistance_Points = 20;
input int      MaxLevels           = 6;

//---+
int OnInit()
{
   if (PivotLookback <= 0 || ClusterDistance_Points <= 0 || MaxLevels <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_SR(" + IntegerToString(PivotLookback) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_SR_");
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
   if (rates_total < PivotLookback * 2) return 0;

   //--- Find swing highs and lows
   double swingHighs[];
   double swingLows[];
   datetime swingHighTimes[];
   datetime swingLowTimes[];
   ArrayResize(swingHighs, rates_total);
   ArrayResize(swingLows, rates_total);
   ArrayResize(swingHighTimes, rates_total);
   ArrayResize(swingLowTimes, rates_total);
   int shCount = 0, slCount = 0;

   int lookback = PivotLookback;

   int i, j;   // MQL4: scope de funcion — declarar una sola vez
   bool clustered;
   string labelName;
   for (i = lookback; i < rates_total - lookback; i++)
   {
      bool isHigh = true;
      bool isLow = true;

      for (j = 1; j <= lookback; j++)
      {
         if (high[i + j] > high[i]) isHigh = false;
         if (low[i + j] < low[i]) isLow = false;
         if (high[i - j] > high[i]) isHigh = false;
         if (low[i - j] < low[i]) isLow = false;
      }

      if (isHigh)
      {
         swingHighs[shCount] = high[i];
         swingHighTimes[shCount] = time[i];
         shCount++;
      }
      if (isLow)
      {
         swingLows[slCount] = low[i];
         swingLowTimes[slCount] = time[i];
         slCount++;
      }
   }

   //--- Cluster resistance levels
   double resLevels[];
   double supLevels[];
   ArrayResize(resLevels, shCount);
   ArrayResize(supLevels, slCount);
   int resCount = 0, supCount = 0;

   double clusterDist = ClusterDistance_Points * Point;

   for (i = 0; i < shCount; i++)
   {
      clustered = false;
      for (j = 0; j < resCount; j++)
      {
         if (MathAbs(swingHighs[i] - resLevels[j]) <= clusterDist)
         {
            resLevels[j] = (resLevels[j] + swingHighs[i]) / 2.0;
            clustered = true;
            break;
         }
      }
      if (!clustered && resCount < MaxLevels)
      {
         resLevels[resCount] = swingHighs[i];
         resCount++;
      }
   }

   for (i = 0; i < slCount; i++)
   {
      clustered = false;
      for (j = 0; j < supCount; j++)
      {
         if (MathAbs(swingLows[i] - supLevels[j]) <= clusterDist)
         {
            supLevels[j] = (supLevels[j] + swingLows[i]) / 2.0;
            clustered = true;
            break;
         }
      }
      if (!clustered && supCount < MaxLevels)
      {
         supLevels[supCount] = swingLows[i];
         supCount++;
      }
   }

   //--- Draw levels
   string resName, supName;

   for (i = 0; i < resCount; i++)
   {
      resName = "GQ_SR_RES_" + IntegerToString(i);
      ObjectDelete(0, resName);
      ObjectCreate(0, resName, OBJ_HLINE, 0, 0, resLevels[i]);
      ObjectSetInteger(0, resName, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, resName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, resName, OBJPROP_STYLE, STYLE_DASH);
   }

   for (i = 0; i < supCount; i++)
   {
      supName = "GQ_SR_SUP_" + IntegerToString(i);
      ObjectDelete(0, supName);
      ObjectCreate(0, supName, OBJ_HLINE, 0, 0, supLevels[i]);
      ObjectSetInteger(0, supName, OBJPROP_COLOR, clrLime);
      ObjectSetInteger(0, supName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, supName, OBJPROP_STYLE, STYLE_DASH);

      labelName = "GQ_SR_SUP_LBL_" + IntegerToString(i);
      ObjectDelete(0, labelName);
      ObjectCreate(0, labelName, OBJ_TEXT, 0, iTime(_Symbol, _Period, 0), supLevels[i]);
      ObjectSetString(0, labelName, OBJPROP_TEXT, "S" + IntegerToString(i + 1) + " " + DoubleToString(supLevels[i], _Digits));
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrLime);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   }

   for (i = 0; i < resCount; i++)
   {
      labelName = "GQ_SR_RES_LBL_" + IntegerToString(i);
      ObjectDelete(0, labelName);
      ObjectCreate(0, labelName, OBJ_TEXT, 0, iTime(_Symbol, _Period, 0), resLevels[i]);
      ObjectSetString(0, labelName, OBJPROP_TEXT, "R" + IntegerToString(i + 1) + " " + DoubleToString(resLevels[i], _Digits));
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   }

   return rates_total;
}
