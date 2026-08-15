//+------------------------------------------------------------------+
//| GQ_Parity_Momentum — Phase B parity EA                            |
//| Strategy: Momentum N=60 — long if ROC(60)>5%, short if <-5%      |
//| Params: InpN=60, InpPct=5 (keep fixed for parity)                 |
//+------------------------------------------------------------------+
#property strict
#property description "Gueta parity: Momentum 60/5 — do not optimize"
input int    InpN    = 60;   // ROC period (keep 60)
input double InpPct  = 5.0;  // ROC threshold % (keep 5)
input double InpLots = 0.10;

#include <Trade/Trade.mqh>
CTrade trade;
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
   trade.PositionClose(_Symbol);
   if (dir > 0) trade.Buy(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_Momentum");
   else         trade.Sell(InpLots, _Symbol, 0.0, 0.0, 0.0, "GQ_Parity_Momentum");
}
//+------------------------------------------------------------------+
