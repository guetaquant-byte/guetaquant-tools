//+------------------------------------------------------------------+
//| GQ_Parity_SMA — Phase B parity EA (matches Gueta harness)         |
//| Strategy: SMA crossover (fast=5, slow=100) — daily EURUSD         |
//| Execution model: signal on CLOSED bar t, order at market on first |
//| tick of bar t+1 (≈ close[t] within tolerance, per parity protocol)|
//| Params fixed: InpFast=5, InpSlow=100 (do not change for parity)   |
//+------------------------------------------------------------------+
#property strict
#property description "Gueta parity: SMA 5/100 — do not optimize"
input int    InpFast = 5;     // Fast SMA period (keep 5)
input int    InpSlow = 100;   // Slow SMA period (keep 100)
input double InpLots  = 0.10; // Fixed lot size (risk neutral for parity)

#include <Trade/Trade.mqh>
CTrade trade;

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
   trade.PositionClose(_Symbol);
   if (dir > 0) trade.Buy(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_SMA");
   else         trade.Sell(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_SMA");
}
//+------------------------------------------------------------------+
