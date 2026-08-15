//+------------------------------------------------------------------+
//| GQ_Parity_RSI2 — Phase B parity EA                                |
//| Strategy: RSI(2) mean reversion — buy <15, sell >85, flat between|
//| Params: InpThreshold=15, InpPeriod=2 (keep fixed for parity)      |
//+------------------------------------------------------------------+
#property strict
#property description "Gueta parity: RSI(2) 15/2 — do not optimize"
input int    InpPeriod    = 2;  // RSI period (keep 2)
input int    InpThreshold = 15; // RSI threshold (keep 15)
input double InpLots      = 0.10;

#include <Trade/Trade.mqh>
CTrade trade;
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
   trade.PositionClose(_Symbol);
   if (dir > 0) trade.Buy(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_RSI2");
   else         trade.Sell(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_RSI2");
}
//+------------------------------------------------------------------+
