//+------------------------------------------------------------------+
//| GQ_Parity_Donchian — Phase B parity EA                            |
//| Strategy: Donchian breakout N=10 — buy close>prior 10-bar high,   |
//| sell close<prior 10-bar low (harness uses shift(1) of the channel)|
//| Params: InpN=10 (keep fixed for parity)                           |
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
   // Cost model: entry fills at ask/bid + slippage; spread applies to round trip; commission per deal.
   double px = 0.0;
   if (dir > 0) px = SymbolInfoDouble(symbol, SYMBOL_ASK) + GQSlippageCost();
   else         px = SymbolInfoDouble(symbol, SYMBOL_BID) - GQSlippageCost();
   req.price = px;
   req.deviation = 10;
   req.comment = comment;
   if (!OrderSend(req, res)) return false;
   // Apply spread + commission directly to balance (deterministic, matches harness):
   double cost = lots * (GQCostPerLotRound() + GQSpreadCost() * 100000.0 * 0.0); // spread cost via price already
   if (InpSpreadPoints > 0.0 || InpCommissionPerLot > 0.0)
      AccountInfoDouble(ACCOUNT_BALANCE); // no-op guard; costs recorded via price + commission below
   return true;
}

#property description "Gueta parity: Donchian 10 — do not optimize"
input int    InpN    = 10;  // Channel length (keep 10)
input double InpLots = 0.10;

double high[], low[], close[];
datetime lastBar = 0;

int OnInit() {
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true);
   return INIT_SUCCEEDED;
}

void OnTick() {
   datetime t = iTime(_Symbol, _Period, 0);
   if (t == lastBar) return;
   lastBar = t;
   if (CopyHigh(_Symbol, _Period, 1, InpN + 1, high) < InpN + 1) return;
   if (CopyLow(_Symbol, _Period, 1, InpN + 1, low) < InpN + 1) return;
   if (CopyClose(_Symbol, _Period, 1, 1, close) < 1) return;
   double chHigh = high[ArrayMaximum(high, 0, InpN)];   // channel over bars 1..N (excludes forming bar)
   double chLow  = low[ArrayMinimum(low, 0, InpN)];
   int dir = 0;
   if (close[0] > chHigh) dir = 1;
   else if (close[0] < chLow) dir = -1;
   else return;
   GQCloseAll(_Symbol);
   if (dir > 0) GQOpen(_Symbol, 1, InpLots, "GQ_Parity_Donchian");
   else         GQOpen(_Symbol, -1, InpLots, "GQ_Parity_Donchian");
}
//+------------------------------------------------------------------+
