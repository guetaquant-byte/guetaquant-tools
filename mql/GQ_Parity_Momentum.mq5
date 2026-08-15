//+------------------------------------------------------------------+
//| GQ_Parity_Momentum — Phase B parity EA                            |
//| Strategy: Momentum N=60 — long if ROC(60)>5%, short if <-5%      |
//| Params: InpN=60, InpPct=5 (keep fixed for parity)                 |
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

#property description "Gueta parity: Momentum 60/5 — do not optimize"
input int    InpN    = 60;   // ROC period (keep 60)
input double InpPct  = 5.0;  // ROC threshold % (keep 5)
input double InpLots = 0.10;

double close[];
datetime lastBar = 0;

int OnInit() { ArraySetAsSeries(close, true); return INIT_SUCCEEDED; }

void OnTick() {
   datetime t = iTime(_Symbol, _Period, 0);
   if (t == lastBar) return;
   lastBar = t;
   if (CopyClose(_Symbol, _Period, 1, InpN + 1, close) < InpN + 1) return;
   double roc = (close[0] / close[InpN] - 1.0) * 100.0;
   int dir = 0;
   if (roc > InpPct) dir = 1;
   else if (roc < -InpPct) dir = -1;
   else return;
   GQCloseAll(_Symbol);
   if (dir > 0) GQOpen(_Symbol, 1, InpLots, "GQ_Parity_Momentum");
   else         GQOpen(_Symbol, -1, InpLots, "GQ_Parity_Momentum");
}
//+------------------------------------------------------------------+
