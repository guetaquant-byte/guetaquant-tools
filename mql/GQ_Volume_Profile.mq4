#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0

//--- input parameters
input int      Rows       = 24;
input int      Lookback   = 100;
input bool     ShowPOC    = true;
input bool     ShowVA     = true;
input int      VAPercent  = 70;

//---+
int OnInit()
{
   if (Rows <= 0 || Lookback <= 0 || VAPercent <= 0 || VAPercent > 100)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
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
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (rates_total < Lookback) return 0;

   int startBar = Lookback;
   if (startBar >= rates_total) startBar = rates_total - 1;

   double maxH = iHigh(_Symbol, _Period, 0);
   double minL = iLow(_Symbol, _Period, 0);

   for (int n = 1; n < startBar; n++)
   {
      double h = iHigh(_Symbol, _Period, n);
      double l = iLow(_Symbol, _Period, n);
      if (h > maxH) maxH = h;
      if (l < minL) minL = l;
   }

   double rowHeight = (maxH - minL) / Rows;
   if (rowHeight <= 0) return 0;

   //--- Initialize volume profile array
   double volProfile[];
   ArrayResize(volProfile, Rows);
   ArrayInitialize(volProfile, 0);

   //--- Distribute volume into price rows
   // i=0 (barra en formacion) excluida: evita repintado
   for (int m = 1; m < startBar; m++)
   {
      double hh = iHigh(_Symbol, _Period, m);
      double ll = iLow(_Symbol, _Period, m);
      double vol = (double)iVolume(_Symbol, _Period, m);

      // Binning ascendente consistente con el calculo de precios (minL + fila*rowHeight)
      int topRow = (int)((hh - minL) / rowHeight);
      int botRow = (int)((ll - minL) / rowHeight);
      if (topRow < 0) topRow = 0;
      if (botRow >= Rows) botRow = Rows - 1;
      if (topRow > botRow) { int t = topRow; topRow = botRow; botRow = t; }

      double volPerRow = vol / (botRow - topRow + 1);
      for (int j = topRow; j <= botRow; j++)
         volProfile[j] += volPerRow;
   }

   //--- Find POC (highest volume row)
   int pocRow = 0;
   double maxVol = 0;
   for (int p = 0; p < Rows; p++)
   {
      if (volProfile[p] > maxVol)
      {
         maxVol = volProfile[p];
         pocRow = p;
      }
   }

   double totalVol = 0;
   for (int v = 0; v < Rows; v++) totalVol += volProfile[v];

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
   if (maxVol <= 0) return rates_total;

   for (int i = 0; i < Rows; i++)
   {
      double rowLow = minL + i * rowHeight;
      double rowHigh = rowLow + rowHeight;

      string name = "GQ_VP_BOX_" + IntegerToString(i);
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, 0, rowHigh, 0, rowLow);

      ObjectSetDouble(0, name, OBJPROP_PRICE1, rowHigh);
      ObjectSetDouble(0, name, OBJPROP_PRICE2, rowLow);
      ObjectSetInteger(0, name, OBJPROP_TIME1, iTime(_Symbol, _Period, Lookback - 1));
      ObjectSetInteger(0, name, OBJPROP_TIME2, iTime(_Symbol, _Period, 0));

      color boxColor = clrDodgerBlue;
      if (i == pocRow) boxColor = clrGold;
      else if (i >= vaLow && i <= vaHigh) boxColor = clrRoyalBlue;

      ObjectSetInteger(0, name, OBJPROP_COLOR, boxColor);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
   }

   //--- Draw POC line
   if (ShowPOC)
   {
      double pocPrice = minL + (pocRow + 0.5) * rowHeight;
      string pocName = "GQ_VP_POC";
      ObjectDelete(0, pocName);
      ObjectCreate(0, pocName, OBJ_HLINE, 0, 0, pocPrice);
      ObjectSetInteger(0, pocName, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, pocName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, pocName, OBJPROP_STYLE, STYLE_SOLID);

      string pocLabel = "GQ_VP_POC_LBL";
      ObjectDelete(0, pocLabel);
      ObjectCreate(0, pocLabel, OBJ_TEXT, 0, iTime(_Symbol, _Period, 0), pocPrice);
      ObjectSetString(0, pocLabel, OBJPROP_TEXT, "POC " + DoubleToString(pocPrice, _Digits));
      ObjectSetInteger(0, pocLabel, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, pocLabel, OBJPROP_FONTSIZE, 8);
   }

   //--- Draw VA lines
   if (ShowVA)
   {
      double vaHighPrice = minL + (vaHigh + 1) * rowHeight;
      double vaLowPrice = minL + vaLow * rowHeight;

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
      ObjectCreate(0, vaHLabel, OBJ_TEXT, 0, iTime(_Symbol, _Period, 0), vaHighPrice);
      ObjectSetString(0, vaHLabel, OBJPROP_TEXT, "VAH " + DoubleToString(vaHighPrice, _Digits));
      ObjectSetInteger(0, vaHLabel, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaHLabel, OBJPROP_FONTSIZE, 8);

      string vaLLabel = "GQ_VP_VAL_LBL";
      ObjectDelete(0, vaLLabel);
      ObjectCreate(0, vaLLabel, OBJ_TEXT, 0, iTime(_Symbol, _Period, 0), vaLowPrice);
      ObjectSetString(0, vaLLabel, OBJPROP_TEXT, "VAL " + DoubleToString(vaLowPrice, _Digits));
      ObjectSetInteger(0, vaLLabel, OBJPROP_COLOR, clrRoyalBlue);
      ObjectSetInteger(0, vaLLabel, OBJPROP_FONTSIZE, 8);
   }

   return rates_total;
}
