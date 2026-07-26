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
int g_atr_handle;
double g_atr_buffer[];
string g_sym;
ENUM_TIMEFRAMES g_tf;

//---+
int OnInit()
{
   if (ATRPeriod <= 0 || Multiplier <= 0.0 || RiskPercent <= 0.0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_sym = _Symbol;
   g_tf = _Period;
   g_atr_handle = iATR(g_sym, g_tf, ATRPeriod);
   if (g_atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create iATR handle: ", GetLastError());
      return INIT_FAILED;
   }
   ArraySetAsSeries(g_atr_buffer, true);
   return INIT_SUCCEEDED;
}

//---+
void OnDeinit(const int reason)
{
   if (g_atr_handle != INVALID_HANDLE)
      IndicatorRelease(g_atr_handle);
   Comment("");
}

//---+
void OnTick()
{
   if (g_atr_handle == INVALID_HANDLE) return;

   if (CopyBuffer(g_atr_handle, 0, 0, 2, g_atr_buffer) < 2)
   {
      Print("CopyBuffer failed: ", GetLastError());
      return;
   }
   double atr = g_atr_buffer[0];
   if (atr <= 0.0) return;

   bool hasLong = false, hasShort = false;
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (PositionSelectByTicket(ticket))
      {
         if (PositionGetString(POSITION_SYMBOL) != g_sym) continue;
         if (PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) hasLong = true;
         if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) hasShort = true;
      }
   }

   int limit = ATRPeriod + 1;
   double close[], high[], low[];
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   if (CopyClose(g_sym, g_tf, 0, limit, close) < limit) return;
   if (CopyHigh(g_sym, g_tf, 0, limit, high) < limit) return;
   if (CopyLow(g_sym, g_tf, 0, limit, low) < limit) return;

   double hl2[];
   ArrayResize(hl2, limit);
   for (int i = 0; i < limit; i++)
   {
      hl2[i] = (high[i] + low[i]) / 2.0;
   }

   double upperBand[], lowerBand[], trend[];
   ArrayResize(upperBand, limit);
   ArrayResize(lowerBand, limit);
   ArrayResize(trend, limit);

   for (int i = 0; i < limit; i++)
   {
      double med = (high[i] + low[i]) / 2.0;
      double r = atr * Multiplier;
      upperBand[i] = med + r;
      lowerBand[i] = med - r;
   }

   for (int i = limit - 2; i >= 0; i--)
   {
      if (close[i] <= upperBand[i + 1])
         lowerBand[i] = MathMax(lowerBand[i], lowerBand[i + 1]);
      if (close[i] >= lowerBand[i + 1])
         upperBand[i] = MathMin(upperBand[i], upperBand[i + 1]);
   }

   for (int i = limit - 1; i >= 0; i--)
   {
      if (i == limit - 1)
      {
         trend[i] = close[i] > upperBand[i] ? 1.0 : -1.0;
      }
      else
      {
         if (trend[i + 1] == 1.0)
            trend[i] = close[i] > lowerBand[i] ? 1.0 : -1.0;
         else
            trend[i] = close[i] < upperBand[i] ? -1.0 : 1.0;
      }
   }

   double currentTrend = trend[0];
   double prevTrend = trend[1];

   if (currentTrend != prevTrend)
   {
      if (currentTrend == 1.0)
      {
         CloseAllShort();
         if (!hasLong)
            OpenOrder(POSITION_TYPE_BUY, atr);
      }
      else
      {
         CloseAllLong();
         if (!hasShort)
            OpenOrder(POSITION_TYPE_SELL, atr);
      }
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
         double lotsize = riskCash / (atr * tickValue);
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
   req.comment = "GQ_ST";

   if (type == POSITION_TYPE_BUY)
   {
      req.type = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_ASK);
      req.sl = req.price - atr;
      req.tp = req.price + atr;
   }
   else
   {
      req.type = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(g_sym, SYMBOL_BID);
      req.sl = req.price + atr;
      req.tp = req.price - atr;
   }

   if (!OrderSend(req, res))
      Print("Order open failed: ", GetLastError(), " retcode: ", res.retcode);
}
