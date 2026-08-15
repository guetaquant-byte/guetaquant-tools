//+------------------------------------------------------------------+
//|                                           GQ_Parity_Donchian.mq5 |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
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
   bool ok = OrderSend(req, res);
   if (!ok) PrintFormat("ORDER FAIL retcode=%d | %s", res.retcode, comment);
   return ok;
}

#property description "Gueta parity: Donchian 10 — do not optimize"
input int    InpN    = 10;  // Channel length (keep 10)
input double InpLots = 0.10;

double high[], low[], close[];
datetime lastBar = 0;


// ── Phase B diagnostics (remove after parity) ──
int g_diag_tick = 0;
void GQDiag(const int dir, const double px) {
   if (g_diag_tick < 3) {
      PrintFormat("GQDiag | %s D1 | bars=%d | tick#%d dir=%d px=%.5f", _Symbol, Bars(_Symbol, PERIOD_D1), g_diag_tick, dir, px);
      g_diag_tick++;
   }
}

int OnInit() {
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true);
   return INIT_SUCCEEDED;
}

void OnTick() {
   datetime t = iTime(_Symbol, _Period, 0);
   if (t == lastBar) return;
   lastBar = t;
   if (CopyHigh(_Symbol, _Period, 1, InpN, high) < InpN) return;   // bars 1..N only (signal bar = bar 1 is close[0]; channel excludes it)
   if (CopyLow(_Symbol, _Period, 1, InpN, low) < InpN) return;
   if (CopyClose(_Symbol, _Period, 1, 1, close) < 1) return;
   double chHigh = high[ArrayMaximum(high, 0, InpN - 1)];   // max over bars 1..N
   double chLow  = low[ArrayMinimum(low, 0, InpN - 1)];
   int dir = 0;
   if (close[0] > chHigh) dir = 1;
   else if (close[0] < chLow) dir = -1;
   else {
      if (PositionSelect(_Symbol)) GQCloseAll(_Symbol);
      return;
   }
   GQDiag(dir, 0.0);
   bool already = PositionSelect(_Symbol);
   bool is_long = already && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;
   bool is_short = already && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL;
   if ((dir > 0 && is_long) || (dir < 0 && is_short)) return;  // signal unchanged: hold
   GQCloseAll(_Symbol);
   if (dir > 0) GQOpen(_Symbol, 1, InpLots, "GQ_Parity_Donchian");
   else         GQOpen(_Symbol, -1, InpLots, "GQ_Parity_Donchian");
}
//+------------------------------------------------------------------+
