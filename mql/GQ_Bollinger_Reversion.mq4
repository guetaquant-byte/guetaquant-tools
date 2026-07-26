#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"

//--- input parameters
input int      BBPeriod      = 20;
input double   BBDeviation   = 2.0;
input int      RSIPeriod     = 14;
input double   RiskPercent   = 1.0;
input int      MagicNumber   = 1004;
input double   LotSize       = 0.1;

//---+
int OnInit()
{
   if (BBPeriod <= 0 || BBDeviation <= 0.0 || RSIPeriod <= 0)
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
   double lower = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double upper = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double middle = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_MAIN, 0);

   if (lower == EMPTY_VALUE || upper == EMPTY_VALUE || middle == EMPTY_VALUE) return;

   double rsi0 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, 0);
   double rsi1 = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, 1);
   if (rsi0 == EMPTY_VALUE) return;

   double close0 = iClose(_Symbol, _Period, 0);
   double close1 = iClose(_Symbol, _Period, 1);

   //--- Volume filter (more volume than previous bar)
   double vol0 = iVolume(_Symbol, _Period, 0);
   double vol1 = iVolume(_Symbol, _Period, 1);

   //--- ATR for SL/TP
   double atr = iATR(_Symbol, _Period, 14, 0);
   if (atr <= 0.0) return;

   bool hasLong = false, hasShort = false;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderType() == OP_BUY) hasLong = true;
      if (OrderType() == OP_SELL) hasShort = true;
   }

   //--- Buy: price touches lower band AND RSI < 30
   if (!hasLong && close0 <= lower && rsi0 < 30.0 && vol0 > vol1)
   {
      double sl = lower - atr;
      if (sl <= 0) sl = close0 - atr * 2;
      double tp = middle;
      int ticket = OrderSend(_Symbol, OP_BUY, LotSize, Ask, 3, sl, tp, "GQ_BB", MagicNumber, 0, clrGreen);
      if (ticket < 0) Print("Buy open failed: ", GetLastError());
   }

   //--- Sell: price touches upper band AND RSI > 70
   if (!hasShort && close0 >= upper && rsi0 > 70.0 && vol0 > vol1)
   {
      double sl = upper + atr;
      double tp = middle;
      int ticket = OrderSend(_Symbol, OP_SELL, LotSize, Bid, 3, sl, tp, "GQ_BB", MagicNumber, 0, clrRed);
      if (ticket < 0) Print("Sell open failed: ", GetLastError());
   }

   //--- Exit on opposite touch
   if (hasLong && close0 >= middle)
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

   if (hasShort && close0 <= middle)
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
}
