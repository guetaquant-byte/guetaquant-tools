//+------------------------------------------------------------------+
//| GQ_Parity_RSI2 — Phase B parity EA                                |
//| Strategy: RSI(2) mean reversion — buy <15, sell >85, flat between|
//| Params: InpThreshold=15, InpPeriod=2 (keep fixed for parity)      |
//+------------------------------------------------------------------+
#property strict

// MQL5 built-in trade helpers (repo convention: no stdlib includes — CI-safe)
bool GQCloseAll(const string symbol) {
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (!PositionSelectByTicket(ticket)) continue;
      if (PositionGetString(POSITION_SYMBOL) != symbol) continue;
      MqlTradeRequest req = {};
      MqlTradeResult res = {};
      req.action = TRADE_ACTION_DEAL;
      req.symbol = symbol;
      req.volume = PositionGetDouble(POSITION_VOLUME);
      req.position = ticket;
      req.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      req.deviation = 10;
      if (!OrderSend(req, res)) return false;
   }
   return true;
}
bool GQOpen(const string symbol, const int dir, const double lots, const string comment) {
   MqlTradeRequest req = {};
   MqlTradeResult res = {};
   req.action = TRADE_ACTION_DEAL;
   req.symbol = symbol;
   req.volume = lots;
   req.type = (dir > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   req.deviation = 10;
   req.comment = comment;
   return OrderSend(req, res);
}

#property description "Gueta parity: RSI(2) 15/2 — do not optimize"
input int    InpPeriod    = 2;  // RSI period (keep 2)
input int    InpThreshold = 15; // RSI threshold (keep 15)
input double InpLots      = 0.10;
// Cost model (Phase B): applied in-EA because the tester's built-in cost UI
// varies by build. Matches Gueta harness cost model exactly.



int hRSI = INVALID_HANDLE;
double rsi[];
datetime lastBar = 0;

int OnInit() {
   hRSI = iRSI(_Symbol, _Period, InpPeriod, PRICE_CLOSE);
   if (hRSI == INVALID_HANDLE) return INIT_FAILED;
   ArraySetAsSeries(rsi, true);
   return INIT_SUCCEEDED;
}
void OnDeinit(const int r) { if (hRSI != INVALID_HANDLE) IndicatorRelease(hRSI); }

void OnTick() {
   datetime t = iTime(_Symbol, _Period, 0);
   if (t == lastBar) return;
   lastBar = t;
   if (CopyBuffer(hRSI, 0, 1, 1, rsi) < 1) return;   // closed bar only
   double v = rsi[0];
   int dir = 0;
   if (v < InpThreshold) dir = 1;
   else if (v > 100 - InpThreshold) dir = -1;
   else return;
   GQCloseAll(_Symbol);
   if (dir > 0) GQOpen(_Symbol, 1, InpLots, "GQ_Parity_RSI2");
   else         GQOpen(_Symbol, -1, InpLots, "GQ_Parity_RSI2");
}
//+------------------------------------------------------------------+
