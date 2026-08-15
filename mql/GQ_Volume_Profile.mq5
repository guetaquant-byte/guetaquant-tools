//+------------------------------------------------------------------+
//|                                           GQ_Volume_Profile.mq5  |
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
input int      Rows       = 24;
input int      Lookback   = 100;
input bool     ShowPOC    = true;
input bool     ShowVA     = true;
input int      VAPercent  = 70;

//--- global
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (Rows <= 0 || Lookback <= 0 || VAPercent <= 0 || VAPercent > 100)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_Volume_Profile(" + IntegerToString(Rows) + "," + IntegerToString(Lookback) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_VP_");
   Comment("");
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (rates_total < Lookback) return 0;

   double high[], low[];
   long volume[];
   datetime time[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(time, true);

   if (CopyHigh(g_sym, g_tf, 0, Lookback, high) < Lookback) return 0;
   if (CopyLow(g_sym, g_tf, 0, Lookback, low) < Lookback) return 0;
   if (CopyTickVolume(g_sym, g_tf, 0, Lookback, volume) < Lookback) return 0;
   if (CopyTime(g_sym, g_tf, 0, Lookback, time) < Lookback) return 0;

   double maxH = high[0];
   double minL = low[0];

   for (int i = 1; i < Lookback; i++)
   {
      if (high[i] > maxH) maxH = high[i];
      if (low[i] < minL) minL = low[i];
   }

   double rowHeight = (maxH - minL) / Rows;
   if (rowHeight <= 0) return 0;

   double volProfile[];
   ArrayResize(volProfile, Rows);
   ArrayInitialize(volProfile, 0);

   //--- Distribute volume into price rows
   for (int i = 0; i < Lookback; i++)
   {
      double h = high[i];
      double l = low[i];
      double vol = (double)volume[i];

      int topRow = (int)((maxH - h) / rowHeight);
      int botRow = (int)((maxH - l) / rowHeight);
      if (topRow < 0) topRow = 0;
      if (botRow >= Rows) botRow = Rows - 1;
      if (topRow > botRow) { int t = topRow; topRow = botRow; botRow = t; }

      double volPerRow = vol / (botRow - topRow + 1);
      for (int j = topRow; j <= botRow; j++)
         volProfile[j] += volPerRow;
   }

   //--- Find POC
   int pocRow = 0;
   double maxVol = 0;
   for (int i = 0; i < Rows; i++)
   {
      if (volProfile[i] > maxVol)
      {
         maxVol = volProfile[i];
         pocRow = i;
      }
   }

   double totalVol = 0;
   for (int i = 0; i < Rows; i++) totalVol += volProfile[i];

   //--- Calculate Value Area
   double vaTarget = totalVol * VAPercent / 100.0;
   double vaCumul = volProfile[pocRow];
   int vaHigh = pocRow, vaLow = pocRow;

   while (vaCumul < vaTarget)
   {
      int nextUp = vaHigh + 1;
      int nextDown = vaLow - 1;
      double volUp = (nextUp < Rows) ? volProfile[nextUp] : -1;
      double volDown = (nextDown >= 0) ? volProfile[nextDown] : -1;

      if (volUp >= volDown && volUp >= 0)
      {
         vaCumul += volUp;
         vaHigh = nextUp;
      }
      else if (volDown >= 0)
      {
         vaCumul += volDown;
         vaLow = nextDown;
      }
      else
         break;

      if (vaCumul >= totalVol) break;
   }

   //--- Draw histogram boxes
   ObjectsDeleteAll(0, "GQ_VP_");

   for (int i = 0; i < Rows; i++)
   {
      double rowLow = minL + i * rowHeight;
      double rowHigh = rowLow + rowHeight;
      double width = volProfile[i] / maxVol * 100 < 5 ? 5 : volProfile[i] / maxVol * 100;

      string name = "GQ_VP_BOX_" + IntegerToString(i);
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, time[Lookback - 1], rowHigh, time[0], rowLow);

      color boxColor = clrDodgerBlue;
      if (i == pocRow) boxColor = clrGold;
      else if (i >= vaLow && i <= vaHigh) boxColor = clrRoyalBlue;

      ObjectSetInteger(0, name, OBJPROP_COLOR, boxColor);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
   }

   int digits = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);

   //--- Draw POC line
   if (ShowPOC)
   {
      double pocPrice = maxH - (pocRow + 0.5) * rowHeight;   // fila 0 = precio superior (binning top-down)
      string pocName = "GQ_VP_POC";
      ObjectDelete(0, pocName);
      ObjectCreate(0, pocName, OBJ_HLINE, 0, 0, pocPrice);
      ObjectSetInteger(0, pocName, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, pocName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, pocName, OBJPROP_STYLE, STYLE_SOLID);

      string pocLabel = "GQ_VP_POC_LBL";
      ObjectDelete(0, pocLabel);
      ObjectCreate(0, pocLabel, OBJ_TEXT, 0, time[0], pocPrice);
      ObjectSetString(0, pocLabel, OBJPROP_TEXT, "POC " + DoubleToString(pocPrice, digits));
      ObjectSetInteger(0, pocLabel, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, pocLabel, OBJPROP_FONTSIZE, 8);
   }

   //--- Draw VA lines
   if (ShowVA)
   {
      double vaHighPrice = maxH - (vaHigh + 1) * rowHeight;
      double vaLowPrice = maxH - vaLow * rowHeight;

      string vaHName = "GQ_VP_VAH";
      ObjectDelete(0, vaHName);
      ObjectCreate(0, vaHName, OBJ_HLINE, 0, 0, vaHighPrice);
      ObjectSetInteger(0, vaHName, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaHName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, vaHName, OBJPROP_STYLE, STYLE_DASH);

      string vaLName = "GQ_VP_VAL";
      ObjectDelete(0, vaLName);
      ObjectCreate(0, vaLName, OBJ_HLINE, 0, 0, vaLowPrice);
      ObjectSetInteger(0, vaLName, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaLName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, vaLName, OBJPROP_STYLE, STYLE_DASH);

      string vaHLabel = "GQ_VP_VAH_LBL";
      ObjectDelete(0, vaHLabel);
      ObjectCreate(0, vaHLabel, OBJ_TEXT, 0, time[0], vaHighPrice);
      ObjectSetString(0, vaHLabel, OBJPROP_TEXT, "VAH " + DoubleToString(vaHighPrice, digits));
      ObjectSetInteger(0, vaHLabel, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaHLabel, OBJPROP_FONTSIZE, 8);

      string vaLLabel = "GQ_VP_VAL_LBL";
      ObjectDelete(0, vaLLabel);
      ObjectCreate(0, vaLLabel, OBJ_TEXT, 0, time[0], vaLowPrice);
      ObjectSetString(0, vaLLabel, OBJPROP_TEXT, "VAL " + DoubleToString(vaLowPrice, digits));
      ObjectSetInteger(0, vaLLabel, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaLLabel, OBJPROP_FONTSIZE, 8);
   }

   return rates_total;
}
