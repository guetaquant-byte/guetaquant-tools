#property copyright "GuetaQuant Tools"
#property link      ""
#property version   "1.00"

//--- input parameters
input int      FastMA        = 20;
input int      SlowMA        = 50;
input int      ATRPeriod     = 14;
input double   RiskPercent   = 2.0;
input int      MagicNumber   = 1005;
input double   LotSize       = 0.1;

datetime g_lastBarTime = 0;

//---+
int OnInit()
{
   if (FastMA <= 0 || SlowMA <= 0 || FastMA >= SlowMA)
   {
      Print("Invalid MA parameters: FastMA must be < SlowMA");
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
bool IsNewBar()
{
   datetime curBar = iTime(_Symbol, _Period, 0);
   if (curBar != g_lastBarTime)
   {
      g_lastBarTime = curBar;
      return true;
   }
   return false;
}

//---+
void OnTick()
{
   if (!IsNewBar()) return;

   double fastMA0 = iMA(_Symbol, _Period, FastMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double slowMA0 = iMA(_Symbol, _Period, SlowMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double fastMA1 = iMA(_Symbol, _Period, FastMA, 0, MODE_EMA, PRICE_CLOSE, 1);
   double slowMA1 = iMA(_Symbol, _Period, SlowMA, 0, MODE_EMA, PRICE_CLOSE, 1);

   if (fastMA0 == EMPTY_VALUE || slowMA0 == EMPTY_VALUE) return;

   double atr = iATR(_Symbol, _Period, ATRPeriod, 0);
   if (atr <= 0.0) return;

   int total = OrdersTotal();
   int posCount = 0;
   for (int i = 0; i < total; i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      posCount++;
   }

   if (posCount >= 1) return;

   if (fastMA0 > slowMA0 && fastMA1 <= slowMA1)
   {
      double sl = Bid - atr * 2.0;
      double tp = Ask + atr * 3.0;
      int ticket = OrderSend(_Symbol, OP_BUY, LotSize, Ask, 3, sl, tp, "GQ_TF", MagicNumber, 0, clrGreen);
      if (ticket < 0) Print("Buy open failed: ", GetLastError());
   }
   else if (fastMA0 < slowMA0 && fastMA1 >= slowMA1)
   {
      double sl = Ask + atr * 2.0;
      double tp = Bid - atr * 3.0;
      int ticket = OrderSend(_Symbol, OP_SELL, LotSize, Bid, 3, sl, tp, "GQ_TF", MagicNumber, 0, clrRed);
      if (ticket < 0) Print("Sell open failed: ", GetLastError());
   }
}
