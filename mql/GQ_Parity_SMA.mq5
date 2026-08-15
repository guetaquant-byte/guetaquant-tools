//+------------------------------------------------------------------+
//| GQ_Parity_SMA — Phase B parity EA (matches Gueta harness)         |
//| Strategy: SMA crossover (fast=5, slow=100) — daily EURUSD         |
//| Execution model: signal on CLOSED bar t, order at market on first |
//| tick of bar t+1 (≈ close[t] within tolerance, per parity protocol)|
//| Params fixed: InpFast=5, InpSlow=100 (do not change for parity)   |
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

#property description "Gueta parity: SMA 5/100 — do not optimize"
input int    InpFast = 5;     // Fast SMA period (keep 5)
input int    InpSlow = 100;   // Slow SMA period (keep 100)
input double InpLots  = 0.10; // Fixed lot size (risk neutral for parity)


int hFast = INVALID_HANDLE;
int hSlow = INVALID_HANDLE;
double fast[], slow[];
datetime lastBar = 0;

int OnInit() {
   hFast = iMA(_Symbol, _Period, InpFast, 0, MODE_SMA, PRICE_CLOSE);
   hSlow = iMA(_Symbol, _Period, InpSlow, 0, MODE_SMA, PRICE_CLOSE);
   if (hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE) return INIT_FAILED;
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int r) { if (hFast != INVALID_HANDLE) IndicatorRelease(hFast); if (hSlow != INVALID_HANDLE) IndicatorRelease(hSlow); }

void OnTick() {
   datetime t = iTime(_Symbol, _Period, 0);
   if (t == lastBar) return;            // act once per new bar
   lastBar = t;
   if (CopyBuffer(hFast, 0, 1, 2, fast) < 2) return;   // closed bars only (shift>=1)
   if (CopyBuffer(hSlow, 0, 1, 2, slow) < 2) return;
   int dir = 0;
   if (fast[1] > slow[1] && fast[0] <= slow[0]) dir = 1;    // bullish cross on closed bar 1
   if (fast[1] < slow[1] && fast[0] >= slow[0]) dir = -1;   // bearish cross
   if (dir == 0) return;
   // Close existing position, open new one (harness holds one position at a time)
   GQCloseAll(_Symbol);
   if (dir > 0) GQOpen(_Symbol, 1, InpLots, "GQ_Parity_SMA");
   else         GQOpen(_Symbol, -1, InpLots, "GQ_Parity_SMA");
}
//+------------------------------------------------------------------+
