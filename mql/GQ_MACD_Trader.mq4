#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"

//--- input parameters
input int      FastEMA        = 12;
input int      SlowEMA        = 26;
input int      SignalSMA      = 9;
input double   RiskPercent    = 2.0;
input int      MagicNumber    = 1002;
input double   LotSize        = 0.1;

//---+
int OnInit()
{
   if (FastEMA <= 0 || SlowEMA <= 0 || SignalSMA <= 0 || FastEMA >= SlowEMA)
   {
      Print("Invalid MA parameters");
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
   double atr = iATR(_Symbol, _Period, 14, 0);
   if (atr <= 0.0) return;

   double macdMain0 = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 0);
   double macdSignal0 = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 0);
   double macdMain1 = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 1);
   double macdSignal1 = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 1);

   if (macdMain0 == EMPTY_VALUE || macdSignal0 == EMPTY_VALUE ||
       macdMain1 == EMPTY_VALUE || macdSignal1 == EMPTY_VALUE) return;

   bool crossAbove = (macdMain1 <= macdSignal1 && macdMain0 > macdSignal0);
   bool crossBelow = (macdMain1 >= macdSignal1 && macdMain0 < macdSignal0);

   bool hasLong = false, hasShort = false;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderType() == OP_BUY) hasLong = true;
      if (OrderType() == OP_SELL) hasShort = true;
   }

   if (crossAbove)
   {
      if (hasShort) CloseAllShort();
      if (!hasLong) OpenOrder(OP_BUY, atr);
   }

   if (crossBelow)
   {
      if (hasLong) CloseAllLong();
      if (!hasShort) OpenOrder(OP_SELL, atr);
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
         lot = MathMax(0.01, MathMin(MarketInfo(_Symbol, MODE_MAXLOT), riskCash / (atr * 1.5 * tickValue)));
   }

   if (type == OP_BUY)
   {
      sl = Bid - atr * 1.5;
      tp = Ask + atr * 3.0;
      int ticket = OrderSend(_Symbol, OP_BUY, lot, Ask, 3, sl, tp, "GQ_MACD", MagicNumber, 0, clrGreen);
      if (ticket < 0) Print("Buy open failed: ", GetLastError());
   }
   else
   {
      sl = Ask + atr * 1.5;
      tp = Bid - atr * 3.0;
      int ticketSell = OrderSend(_Symbol, OP_SELL, lot, Bid, 3, sl, tp, "GQ_MACD", MagicNumber, 0, clrRed);
      if (ticketSell < 0) Print("Sell open failed: ", GetLastError());
   }
}
