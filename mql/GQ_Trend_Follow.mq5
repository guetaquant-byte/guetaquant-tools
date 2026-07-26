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

//--- global variables
int g_fastMA_handle;
int g_slowMA_handle;
int g_atr_handle;
double g_fastMA_buf[];
double g_slowMA_buf[];
double g_atr_buf[];
string g_sym;
ENUM_TIMEFRAMES g_tf;
datetime g_lastBarTime = 0;

//---+
int OnInit()
{
   if (FastMA <= 0 || SlowMA <= 0 || FastMA >= SlowMA)
   {
      Print("Invalid MA parameters: FastMA must be < SlowMA");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_fastMA_handle = iMA(g_sym, g_tf, FastMA, 0, MODE_EMA, PRICE_CLOSE);
   if (g_fastMA_handle == INVALID_HANDLE)
   {
      Print("Failed to create fast MA handle: ", GetLastError());
      return INIT_FAILED;
   }
   g_slowMA_handle = iMA(g_sym, g_tf, SlowMA, 0, MODE_EMA, PRICE_CLOSE);
   if (g_slowMA_handle == INVALID_HANDLE)
   {
      Print("Failed to create slow MA handle: ", GetLastError());
      return INIT_FAILED;
   }
   g_atr_handle = iATR(g_sym, g_tf, ATRPeriod);
   if (g_atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create iATR handle: ", GetLastError());
      return INIT_FAILED;
   }
   ArraySetAsSeries(g_fastMA_buf, true);
   ArraySetAsSeries(g_slowMA_buf, true);
   ArraySetAsSeries(g_atr_buf, true);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_fastMA_handle != INVALID_HANDLE) IndicatorRelease(g_fastMA_handle);
   if (g_slowMA_handle != INVALID_HANDLE) IndicatorRelease(g_slowMA_handle);
   if (g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   Comment("");
}

//---+
bool IsNewBar()
{
   datetime curBar[];
   ArraySetAsSeries(curBar, true);
   if (CopyTime(g_sym, g_tf, 0, 1, curBar) < 1) return false;
   if (curBar[0] != g_lastBarTime)
   {
      g_lastBarTime = curBar[0];
      return true;
   }
   return false;
}

//---+
void OnTick()
{
   if (!IsNewBar()) return;

   if (g_fastMA_handle == INVALID_HANDLE || g_slowMA_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE)
      return;

   if (CopyBuffer(g_fastMA_handle, 0, 0, 3, g_fastMA_buf) < 3) return;
   if (CopyBuffer(g_slowMA_handle, 0, 0, 3, g_slowMA_buf) < 3) return;
   if (CopyBuffer(g_atr_handle, 0, 0, 2, g_atr_buf) < 2) return;

   double fastMA0 = g_fastMA_buf[0];
   double slowMA0 = g_slowMA_buf[0];
   double fastMA1 = g_fastMA_buf[1];
   double slowMA1 = g_slowMA_buf[1];
   double atr = g_atr_buf[0];

   if (atr <= 0.0) return;

   int posCount = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (!PositionSelectByTicket(ticket)) continue;
      if (PositionGetString(POSITION_SYMBOL) != g_sym) continue;
      if (PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      posCount++;
   }

   if (posCount >= 1) return;

   MqlTradeRequest req = {};
   MqlTradeResult res = {};
   req.action = TRADE_ACTION_DEAL;
   req.symbol = g_sym;
   req.volume = LotSize;
   req.deviation = 3;
   req.magic = MagicNumber;
   req.comment = "GQ_TF";

   if (fastMA0 > slowMA0 && fastMA1 <= slowMA1)
   {
      req.type = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_ASK);
      req.sl = req.price - atr * 2.0;
      req.tp = req.price + atr * 3.0;
      if (!OrderSend(req, res))
         Print("Buy open failed: ", GetLastError(), " retcode: ", res.retcode);
   }
   else if (fastMA0 < slowMA0 && fastMA1 >= slowMA1)
   {
      req.type = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_BID);
      req.sl = req.price + atr * 2.0;
      req.tp = req.price - atr * 3.0;
      if (!OrderSend(req, res))
         Print("Sell open failed: ", GetLastError(), " retcode: ", res.retcode);
   }
}
