#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7
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

//--- global
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (Tenkan <= 0 || Kijun <= 0 || Senkou <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   SetIndexBuffer(0, g_tenkan, INDICATOR_DATA);
   SetIndexBuffer(1, g_kijun, INDICATOR_DATA);
   SetIndexBuffer(2, g_senkouA, INDICATOR_DATA);
   SetIndexBuffer(3, g_senkouB, INDICATOR_DATA);
   SetIndexBuffer(4, g_chikou, INDICATOR_DATA);
   SetIndexBuffer(5, g_cloudA, INDICATOR_DATA);
   SetIndexBuffer(6, g_cloudB, INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME, "GQ_Ichimoku(" + IntegerToString(Tenkan) + "," + IntegerToString(Kijun) + "," + IntegerToString(Senkou) + ")");
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "GQ_ICH_");
   Comment("");
}

//---+
double CalcHighLow(const double &high[], const double &low[], int start, int len, bool isHigh)
{
   double val = isHigh ? 0 : EMPTY_VALUE;
   for (int i = start; i < start + len; i++)
   {
      if (isHigh)
      {
         if (high[i] > val) val = high[i];
      }
      else
      {
         if (low[i] < val || val == EMPTY_VALUE) val = low[i];
      }
   }
   return val;
}

//---+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (rates_total < Senkou + Kijun + 1) return 0;

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

   int limit = rates_total - 1;
   if (prev_calculated > 0 && prev_calculated < rates_total)
      limit = rates_total - prev_calculated;

   for (int i = limit; i >= 0; i--)
   {
      if (i >= Tenkan - 1)
      {
         double hiTen = CalcHighLow(high, low, i, Tenkan, true);
         double loTen = CalcHighLow(high, low, i, Tenkan, false);
         g_tenkan[i] = (hiTen + loTen) / 2.0;
      }
      else
         g_tenkan[i] = EMPTY_VALUE;

      if (i >= Kijun - 1)
      {
         double hiKij = CalcHighLow(high, low, i, Kijun, true);
         double loKij = CalcHighLow(high, low, i, Kijun, false);
         g_kijun[i] = (hiKij + loKij) / 2.0;
      }
      else
         g_kijun[i] = EMPTY_VALUE;

      if (i + Kijun < rates_total)
      {
         if (i >= Tenkan - 1 && i >= Kijun - 1)
         {
            double hiTa = CalcHighLow(high, low, i, Tenkan, true);
            double loTa = CalcHighLow(high, low, i, Tenkan, false);
            double hiKa = CalcHighLow(high, low, i, Kijun, true);
            double loKa = CalcHighLow(high, low, i, Kijun, false);
            double tenA = (hiTa + loTa) / 2.0;
            double kijA = (hiKa + loKa) / 2.0;
            g_senkouA[i + Kijun] = (tenA + kijA) / 2.0;
         }
      }

      if (i + Kijun < rates_total && i >= Senkou - 1)
      {
         double hiSb = CalcHighLow(high, low, i, Senkou, true);
         double loSb = CalcHighLow(high, low, i, Senkou, false);
         g_senkouB[i + Kijun] = (hiSb + loSb) / 2.0;
      }

      if (i >= Kijun)
         g_chikou[i] = close[i - Kijun];
      else
         g_chikou[i] = EMPTY_VALUE;

      if (i < rates_total - Kijun)
      {
         g_cloudA[i] = g_senkouA[i];
         g_cloudB[i] = g_senkouB[i];
      }
   }

   //--- Signals
   if (limit == 0)
   {
      double ten0 = g_tenkan[0], ten1 = g_tenkan[1];
      double kij0 = g_kijun[0], kij1 = g_kijun[1];
      double close0 = close[0], close1 = close[1];
      double point = SymbolInfoDouble(g_sym, SYMBOL_POINT);

      if (ten0 > kij0 && ten1 <= kij1)
      {
         if (!SignalOnlyCloud || close0 > kij0)
         {
            CreateArrow("GQ_ICH_TK_BUY_", time[0], low[0] - 15 * point, 233, clrLime);
            CreateLabel("GQ_ICH_TK_LBL_", time[0], low[0] - 25 * point, "TK BUY", clrLime);
         }
      }
      if (ten0 < kij0 && ten1 >= kij1)
      {
         if (!SignalOnlyCloud || close0 < kij0)
         {
            CreateArrow("GQ_ICH_TK_SELL_", time[0], high[0] + 15 * point, 234, clrRed);
            CreateLabel("GQ_ICH_TK_LBL_", time[0], high[0] + 25 * point, "TK SELL", clrRed);
         }
      }

      if (close0 > kij0 && close1 <= kij1)
      {
         CreateArrow("GQ_ICH_KJ_BUY_", time[0], low[0] - 20 * point, 233, clrDodgerBlue);
         CreateLabel("GQ_ICH_KJ_LBL_", time[0], low[0] - 30 * point, "KJ BUY", clrDodgerBlue);
      }
      if (close0 < kij0 && close1 >= kij1)
      {
         CreateArrow("GQ_ICH_KJ_SELL_", time[0], high[0] + 20 * point, 234, clrTomato);
         CreateLabel("GQ_ICH_KJ_LBL_", time[0], high[0] + 30 * point, "KJ SELL", clrTomato);
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
