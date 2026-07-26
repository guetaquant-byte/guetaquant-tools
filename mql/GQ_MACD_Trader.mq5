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

//--- global variables
int g_macd_handle;
int g_atr_handle;
double g_macd_main[];
double g_macd_signal[];
double g_atr_buf[];
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (FastEMA <= 0 || SlowEMA <= 0 || SignalSMA <= 0 || FastEMA >= SlowEMA)
   {
      Print("Invalid MA parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_macd_handle = iMACD(g_sym, g_tf, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);
   if (g_macd_handle == INVALID_HANDLE)
   {
      Print("Failed to create iMACD handle: ", GetLastError());
      return INIT_FAILED;
   }
   g_atr_handle = iATR(g_sym, g_tf, 14);
   if (g_atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create iATR handle: ", GetLastError());
      return INIT_FAILED;
   }
   ArraySetAsSeries(g_macd_main, true);
   ArraySetAsSeries(g_macd_signal, true);
   ArraySetAsSeries(g_atr_buf, true);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_macd_handle != INVALID_HANDLE) IndicatorRelease(g_macd_handle);
   if (g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   Comment("");
}

//---+
void OnTick()
{
   if (g_macd_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE) return;

   if (CopyBuffer(g_macd_handle, 0, 0, 3, g_macd_main) < 3) return;
   if (CopyBuffer(g_macd_handle, 1, 0, 3, g_macd_signal) < 3) return;
   if (CopyBuffer(g_atr_handle, 0, 0, 2, g_atr_buf) < 2) return;

   double macdMain0 = g_macd_main[0];
   double macdSignal0 = g_macd_signal[0];
   double macdMain1 = g_macd_main[1];
   double macdSignal1 = g_macd_signal[1];

   double atr = g_atr_buf[0];
   if (atr <= 0.0) return;

   bool crossAbove = (macdMain1 <= macdSignal1 && macdMain0 > macdSignal0);
   bool crossBelow = (macdMain1 >= macdSignal1 && macdMain0 < macdSignal0);

   bool hasLong = false, hasShort = false;
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (!PositionSelectByTicket(ticket)) continue;
      if (PositionGetString(POSITION_SYMBOL) != g_sym) continue;
      if (PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) hasLong = true;
      if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) hasShort = true;
   }

   if (crossAbove)
   {
      if (hasShort) CloseAllShort();
      if (!hasLong) OpenOrder(POSITION_TYPE_BUY, atr);
   }

   if (crossBelow)
   {
      if (hasLong) CloseAllLong();
      if (!hasShort) OpenOrder(POSITION_TYPE_SELL, atr);
   }
}

//---+
void CloseAllLong()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (!PositionSelectByTicket(ticket)) continue;
      if (PositionGetString(POSITION_SYMBOL) != g_sym) continue;
      if (PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         MqlTradeRequest req = {};
         MqlTradeResult res = {};
         req.action = TRADE_ACTION_DEAL;
         req.symbol = g_sym;
         req.volume = PositionGetDouble(POSITION_VOLUME);
         req.type = ORDER_TYPE_SELL;
         req.price = SymbolInfoDouble(g_sym, SYMBOL_BID);
         req.deviation = 3;
         req.position = ticket;
         if (!OrderSend(req, res))
            Print("Close long failed: ", GetLastError(), " retcode: ", res.retcode);
      }
   }
}

//---+
void CloseAllShort()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (!PositionSelectByTicket(ticket)) continue;
      if (PositionGetString(POSITION_SYMBOL) != g_sym) continue;
      if (PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      {
         MqlTradeRequest req = {};
         MqlTradeResult res = {};
         req.action = TRADE_ACTION_DEAL;
         req.symbol = g_sym;
         req.volume = PositionGetDouble(POSITION_VOLUME);
         req.type = ORDER_TYPE_BUY;
         req.price = SymbolInfoDouble(g_sym, SYMBOL_ASK);
         req.deviation = 3;
         req.position = ticket;
         if (!OrderSend(req, res))
            Print("Close short failed: ", GetLastError(), " retcode: ", res.retcode);
      }
   }
}

//---+
void OpenOrder(ENUM_POSITION_TYPE type, double atr)
{
   double lot = LotSize;
   if (RiskPercent > 0.0 && atr > 0.0)
   {
      double riskCash = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100.0;
      double tickValue = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE);
      if (tickValue > 0.0)
      {
         double lotsize = riskCash / (atr * 1.5 * tickValue);
         double step = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_STEP);
         lot = MathMax(SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MIN),
                       MathMin(SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MAX),
                               MathRound(lotsize / step) * step));
      }
   }

   MqlTradeRequest req = {};
   MqlTradeResult res = {};
   req.action = TRADE_ACTION_DEAL;
   req.symbol = g_sym;
   req.volume = lot;
   req.deviation = 3;
   req.magic = MagicNumber;
   req.comment = "GQ_MACD";

   if (type == POSITION_TYPE_BUY)
   {
      req.type = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_ASK);
      req.sl = req.price - atr * 1.5;
      req.tp = req.price + atr * 3.0;
   }
   else
   {
      req.type = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_BID);
      req.sl = req.price + atr * 1.5;
      req.tp = req.price - atr * 3.0;
   }

   if (!OrderSend(req, res))
      Print("Order open failed: ", GetLastError(), " retcode: ", res.retcode);
}
