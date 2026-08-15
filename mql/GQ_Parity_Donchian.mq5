//+------------------------------------------------------------------+
//| GQ_Parity_Donchian — Phase B parity EA                            |
//| Strategy: Donchian breakout N=10 — buy close>prior 10-bar high,   |
//| sell close<prior 10-bar low (harness uses shift(1) of the channel)|
//| Params: InpN=10 (keep fixed for parity)                           |
//+------------------------------------------------------------------+
#property strict
#property description "Gueta parity: Donchian 10 — do not optimize"
input int    InpN    = 10;  // Channel length (keep 10)
input double InpLots = 0.10;

#include <Trade/Trade.mqh>
CTrade trade;
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
   trade.PositionClose(_Symbol);
   if (dir > 0) trade.Buy(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_Donchian");
   else         trade.Sell(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_Donchian");
}
//+------------------------------------------------------------------+
