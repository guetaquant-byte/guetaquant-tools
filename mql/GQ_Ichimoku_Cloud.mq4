#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumBlue
#property indicator_width1  1
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  1
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrForestGreen
#property indicator_width3  1
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSaddleBrown
#property indicator_width4  1
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrchid
#property indicator_width5  1
#property indicator_type6   DRAW_FILLING
#property indicator_color6  clrPaleGreen
#property indicator_color7  clrThistle

//--- input parameters
input int      Tenkan      = 9;
input int      Kijun       = 26;
input int      Senkou      = 52;
input bool     SignalOnlyCloud = true;

//--- indicator buffers
double g_tenkan[];
double g_kijun[];
double g_senkouA[];
double g_senkouB[];
double g_chikou[];
double g_cloudA[];
double g_cloudB[];

//---+
int OnInit()
{
   if (Tenkan <= 0 || Kijun <= 0 || Senkou <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   SetIndexBuffer(0, g_tenkan);
   SetIndexBuffer(1, g_kijun);
   SetIndexBuffer(2, g_senkouA);
   SetIndexBuffer(3, g_senkouB);
   SetIndexBuffer(4, g_chikou);
   SetIndexBuffer(5, g_cloudA);
   SetIndexBuffer(6, g_cloudB);
   // Buffers en modo serie: indice 0 = barra actual (consistente con iHigh(shift))
   ArraySetAsSeries(g_tenkan, true);
   ArraySetAsSeries(g_kijun, true);
   ArraySetAsSeries(g_senkouA, true);
   ArraySetAsSeries(g_senkouB, true);
   ArraySetAsSeries(g_chikou, true);
   ArraySetAsSeries(g_cloudA, true);
   ArraySetAsSeries(g_cloudB, true);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_Ichimoku(" + IntegerToString(Tenkan) + "," + IntegerToString(Kijun) + "," + IntegerToString(Senkou) + ")");
   SetIndexShift(5, Kijun);
   SetIndexShift(6, Kijun);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_ICH_");
   Comment("");
}

//---+
double CalcHighLow(int start, int len, bool isHigh)
{
   double val = isHigh ? 0 : EMPTY_VALUE;
   for (int i = start; i < start + len; i++)
   {
      double h = iHigh(_Symbol, _Period, i);
      double l = iLow(_Symbol, _Period, i);
      if (isHigh)
      {
         if (h > val) val = h;
      }
      else
      {
         if (l < val || val == EMPTY_VALUE) val = l;
      }
   }
   return val;
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
   if (rates_total < Senkou + Kijun + 1) return 0;

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   int limit = rates_total - 1;
   if (prev_calculated > 0) limit = rates_total - prev_calculated;
   else limit = rates_total - 1;

   for (int i = limit; i >= 0; i--)
   {
      //--- Tenkan-sen
      if (i >= Tenkan - 1)
      {
         double hiTen = CalcHighLow(i, Tenkan, true);
         double loTen = CalcHighLow(i, Tenkan, false);
         g_tenkan[i] = (hiTen + loTen) / 2.0;
      }
      else
         g_tenkan[i] = EMPTY_VALUE;

      //--- Kijun-sen
      if (i >= Kijun - 1)
      {
         double hiKij = CalcHighLow(i, Kijun, true);
         double loKij = CalcHighLow(i, Kijun, false);
         g_kijun[i] = (hiKij + loKij) / 2.0;
      }
      else
         g_kijun[i] = EMPTY_VALUE;

      //--- Senkou A (shifted forward Kijun)
      if (i + Kijun < rates_total)
      {
         if (i >= Tenkan - 1 && i >= Kijun - 1)
         {
            double hiTa = CalcHighLow(i, Tenkan, true);
            double loTa = CalcHighLow(i, Tenkan, false);
            double hiKa = CalcHighLow(i, Kijun, true);
            double loKa = CalcHighLow(i, Kijun, false);
            double tenA = (hiTa + loTa) / 2.0;
            double kijA = (hiKa + loKa) / 2.0;
            g_senkouA[i + Kijun] = (tenA + kijA) / 2.0;
         }
      }

      //--- Senkou B (shifted forward Kijun)
      if (i + Kijun < rates_total && i >= Senkou - 1)
      {
         double hiSb = CalcHighLow(i, Senkou, true);
         double loSb = CalcHighLow(i, Senkou, false);
         g_senkouB[i + Kijun] = (hiSb + loSb) / 2.0;
      }

      //--- Chikou (shifted backward Kijun)
      if (i >= Kijun)
         g_chikou[i] = close[i - Kijun];
      else
         g_chikou[i] = EMPTY_VALUE;

      //--- Cloud fill buffers
      if (i < rates_total - Kijun)
      {
         g_cloudA[i] = g_senkouA[i];
         g_cloudB[i] = g_senkouB[i];
      }
   }

   //--- Generate signals on new bar
   if (limit == 0)
   {
      double ten0 = g_tenkan[0], ten1 = g_tenkan[1];
      double kij0 = g_kijun[0], kij1 = g_kijun[1];
      double close0 = close[0];
      bool priceAboveKijun = close0 > kij0;
      bool priceBelowKijun = close0 < kij0;

      //--- TK cross
      if (ten0 > kij0 && ten1 <= kij1)
      {
         if (!SignalOnlyCloud || priceAboveKijun)
         {
            CreateArrow("GQ_ICH_TK_BUY_", time[0], low[0] - 15 * Point, 233, clrLime);
            CreateLabel("GQ_ICH_TK_LBL_", time[0], low[0] - 25 * Point, "TK BUY", clrLime);
         }
      }
      if (ten0 < kij0 && ten1 >= kij1)
      {
         if (!SignalOnlyCloud || priceBelowKijun)
         {
            CreateArrow("GQ_ICH_TK_SELL_", time[0], high[0] + 15 * Point, 234, clrRed);
            CreateLabel("GQ_ICH_TK_LBL_", time[0], high[0] + 25 * Point, "TK SELL", clrRed);
         }
      }

      //--- Price / Kijun cross
      double close1 = close[1];
      if (close0 > kij0 && close1 <= kij1)
      {
         CreateArrow("GQ_ICH_KJ_BUY_", time[0], low[0] - 20 * Point, 233, clrDodgerBlue);
         CreateLabel("GQ_ICH_KJ_LBL_", time[0], low[0] - 30 * Point, "KJ BUY", clrDodgerBlue);
      }
      if (close0 < kij0 && close1 >= kij1)
      {
         CreateArrow("GQ_ICH_KJ_SELL_", time[0], high[0] + 20 * Point, 234, clrTomato);
         CreateLabel("GQ_ICH_KJ_LBL_", time[0], high[0] + 30 * Point, "KJ SELL", clrTomato);
      }
   }

   return rates_total;
}

//---+
void CreateArrow(string prefix, datetime t, double p, int code, color clr)
{
   string name = prefix + IntegerToString(t);
   ObjectCreate(0, name, OBJ_ARROW, 0, t, p);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
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
