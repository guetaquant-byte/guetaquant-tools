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

//--- global variables
int g_bb_handle;
int g_rsi_handle;
int g_atr_handle;
double g_bb_upper[];
double g_bb_middle[];
double g_bb_lower[];
double g_rsi_buf[];
double g_atr_buf[];
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (BBPeriod <= 0 || BBDeviation <= 0.0 || RSIPeriod <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_bb_handle = iBands(g_sym, g_tf, BBPeriod, 0, BBDeviation, PRICE_CLOSE);
   if (g_bb_handle == INVALID_HANDLE)
   {
      Print("Failed to create iBands handle: ", GetLastError());
      return INIT_FAILED;
   }
   g_rsi_handle = iRSI(g_sym, g_tf, RSIPeriod, PRICE_CLOSE);
   if (g_rsi_handle == INVALID_HANDLE)
   {
      Print("Failed to create iRSI handle: ", GetLastError());
      return INIT_FAILED;
   }
   g_atr_handle = iATR(g_sym, g_tf, 14);
   if (g_atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create iATR handle: ", GetLastError());
      return INIT_FAILED;
   }
   ArraySetAsSeries(g_bb_upper, true);
   ArraySetAsSeries(g_bb_middle, true);
   ArraySetAsSeries(g_bb_lower, true);
   ArraySetAsSeries(g_rsi_buf, true);
   ArraySetAsSeries(g_atr_buf, true);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_bb_handle != INVALID_HANDLE) IndicatorRelease(g_bb_handle);
   if (g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
   if (g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   Comment("");
}

//---+
void OnTick()
{
   if (g_bb_handle == INVALID_HANDLE || g_rsi_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE) return;

   if (CopyBuffer(g_bb_handle, 0, 0, 3, g_bb_middle) < 3) return;
   if (CopyBuffer(g_bb_handle, 1, 0, 3, g_bb_upper) < 3) return;
   if (CopyBuffer(g_bb_handle, 2, 0, 3, g_bb_lower) < 3) return;
   if (CopyBuffer(g_rsi_handle, 0, 0, 3, g_rsi_buf) < 3) return;
   if (CopyBuffer(g_atr_handle, 0, 0, 2, g_atr_buf) < 2) return;

   double lower = g_bb_lower[0];
   double upper = g_bb_upper[0];
   double middle = g_bb_middle[0];
   double rsi0 = g_rsi_buf[0];
   double rsi1 = g_rsi_buf[1];
   double atr = g_atr_buf[0];

   if (lower == EMPTY_VALUE || upper == EMPTY_VALUE || middle == EMPTY_VALUE) return;
   if (atr <= 0.0) return;

   double close[], volume[];
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   if (CopyClose(g_sym, g_tf, 0, 3, close) < 3) return;
   if (CopyTickVolume(g_sym, g_tf, 0, 3, volume) < 3) return;

   double close0 = close[0];
   double close1 = close[1];
   double vol0 = volume[0];
   double vol1 = volume[1];

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

   //--- Buy: price touches lower band AND RSI < 30 with volume confirmation
   if (!hasLong && close0 <= lower && rsi0 < 30.0 && vol0 > vol1)
   {
      MqlTradeRequest req = {};
      MqlTradeResult res = {};
      req.action = TRADE_ACTION_DEAL;
      req.symbol = g_sym;
      req.volume = LotSize;
      req.type = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_ASK);
      req.sl = lower - atr;
      req.tp = middle;
      req.deviation = 3;
      req.magic = MagicNumber;
      req.comment = "GQ_BB";
      if (!OrderSend(req, res))
         Print("Buy open failed: ", GetLastError(), " retcode: ", res.retcode);
   }

   //--- Sell: price touches upper band AND RSI > 70 with volume confirmation
   if (!hasShort && close0 >= upper && rsi0 > 70.0 && vol0 > vol1)
   {
      MqlTradeRequest req = {};
      MqlTradeResult res = {};
      req.action = TRADE_ACTION_DEAL;
      req.symbol = g_sym;
      req.volume = LotSize;
      req.type = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_BID);
      req.sl = upper + atr;
      req.tp = middle;
      req.deviation = 3;
      req.magic = MagicNumber;
      req.comment = "GQ_BB";
      if (!OrderSend(req, res))
         Print("Sell open failed: ", GetLastError(), " retcode: ", res.retcode);
   }

   //--- Exit at middle band
   if (hasLong && close0 >= middle)
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

   if (hasShort && close0 <= middle)
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
}
