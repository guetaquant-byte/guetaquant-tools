#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"

//--- input parameters
input int      ATRPeriod       = 10;
input double   Multiplier      = 3.0;
input double   RiskPercent     = 2.0;
input int      MagicNumber     = 1001;
input double   LotSize         = 0.1;

//--- global variables
double g_supertrend[];
double g_trend[];
int g_atr_handle;

//---+
int OnInit()
{
   if (ATRPeriod <= 0 || Multiplier <= 0.0 || RiskPercent <= 0.0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   Comment("");
}

//---+
void OnTick()
{
   double atr = iATR(_Symbol, _Period, ATRPeriod, 0);
   if (atr <= 0.0) return;

   int total = OrdersTotal();
   bool hasLong = false, hasShort = false;
   for (int i = 0; i < total; i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderType() == OP_BUY) hasLong = true;
      if (OrderType() == OP_SELL) hasShort = true;
   }

   // Ventana completa (200 barras) para recursion correcta del SuperTrend
   int limit = MathMin(200, Bars(_Symbol, _Period));
   double hl2[];
   ArrayResize(hl2, limit);
   for (int i = 0; i < limit; i++)
   {
      hl2[i] = (iHigh(_Symbol, _Period, i) + iLow(_Symbol, _Period, i)) / 2.0;
   }

   double upperBand[], lowerBand[];
   ArrayResize(upperBand, limit);
   ArrayResize(lowerBand, limit);
   double trend[];
   ArrayResize(trend, limit);

   for (int i = 0; i < limit; i++)
   {
      double med = (iHigh(_Symbol, _Period, i) + iLow(_Symbol, _Period, i)) / 2.0;
      double r = iATR(_Symbol, _Period, ATRPeriod, i) * Multiplier;   // ATR por barra
      upperBand[i] = med + r;
      lowerBand[i] = med - r;
   }

   for (int i = limit - 2; i >= 0; i--)
   {
      if (iClose(_Symbol, _Period, i) <= upperBand[i + 1])
         lowerBand[i] = MathMax(lowerBand[i], lowerBand[i + 1]);
      if (iClose(_Symbol, _Period, i) >= lowerBand[i + 1])
         upperBand[i] = MathMin(upperBand[i], upperBand[i + 1]);
   }

   for (int i = limit - 1; i >= 0; i--)
   {
      if (i == limit - 1)
      {
         trend[i] = iClose(_Symbol, _Period, i) > upperBand[i] ? 1.0 : -1.0;
      }
      else
      {
         if (trend[i + 1] == 1.0)
            trend[i] = iClose(_Symbol, _Period, i) > lowerBand[i] ? 1.0 : -1.0;
         else
            trend[i] = iClose(_Symbol, _Period, i) < upperBand[i] ? -1.0 : 1.0;
      }
   }

   double currentTrend = trend[0];
   double prevTrend = trend[1];

   if (currentTrend != prevTrend)
   {
      if (currentTrend == 1.0)
      {
         //--- Flip to long: close shorts, open long
         CloseAllShort();
         if (!hasLong)
            OpenOrder(OP_BUY, atr);
      }
      else
      {
         //--- Flip to short: close longs, open short
         CloseAllLong();
         if (!hasShort)
            OpenOrder(OP_SELL, atr);
      }
   }
}

//---+
void CloseAllLong()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderType() == OP_BUY)
      {
         if (!OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE))
            Print("Close long failed: ", GetLastError());
      }
   }
}

//---+
void CloseAllShort()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderType() == OP_SELL)
      {
         if (!OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE))
            Print("Close short failed: ", GetLastError());
      }
   }
}

//---+
void OpenOrder(int type, double atr)
{
   double sl = 0.0, tp = 0.0;
   double lot = LotSize;
   if (RiskPercent > 0.0 && atr > 0.0)
   {
      double riskCash = AccountBalance() * RiskPercent / 100.0;
      double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
      if (tickValue > 0.0)
         lot = MathMax(0.01, MathMin(MarketInfo(_Symbol, MODE_MAXLOT), riskCash / (atr * tickValue)));
   }

   if (type == OP_BUY)
   {
      sl = Bid - atr;
      tp = Ask + atr;
      int ticket = OrderSend(_Symbol, OP_BUY, lot, Ask, 3, sl, tp, "GQ_ST", MagicNumber, 0, clrGreen);
      if (ticket < 0) Print("Buy open failed: ", GetLastError());
   }
   else
   {
      sl = Ask + atr;
      tp = Bid - atr;
      int ticket = OrderSend(_Symbol, OP_SELL, lot, Bid, 3, sl, tp, "GQ_ST", MagicNumber, 0, clrRed);
      if (ticket < 0) Print("Sell open failed: ", GetLastError());
   }
}
