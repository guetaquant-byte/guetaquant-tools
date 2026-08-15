//+------------------------------------------------------------------+
//|                                           GQ_Breakout_Orb.cs     |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Breakout_Orb : Robot
    {
        [Parameter("ORB Minutes", Group = "Opening Range", DefaultValue = 30)]
        public int OrbMinutes { get; set; }

        [Parameter("Entry Offset (Pips)", Group = "Entry", DefaultValue = 5)]
        public double EntryOffset { get; set; }

        [Parameter("SL ATR Multiplier", Group = "Risk", DefaultValue = 1.5)]
        public double SL_ATR_Multiplier { get; set; }

        [Parameter("TP Ratio", Group = "Risk", DefaultValue = 2.0)]
        public double TP_Ratio { get; set; }

        [Parameter("Max Trades Per Day", Group = "Risk", DefaultValue = 3)]
        public int MaxTradesPerDay { get; set; }

        [Parameter("Max Spread", Group = "Filter", DefaultValue = 20)]
        public double MaxSpread { get; set; }

        [Parameter("ATR Period", Group = "ATR", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        [Parameter("Fixed Lot Size", Group = "Risk", DefaultValue = 0.1)]
        public double LotSize { get; set; }

        private AverageTrueRange _atr;
        private DateTime _sessionDate;
        private double _rangeHigh;
        private double _rangeLow;
        private bool _rangeSet;
        private int _tradesToday;
        private DateTime _tradeDate;

        protected override void OnStart()
        {
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _sessionDate = Server.Time.Date;
            _tradeDate = Server.Time.Date;
            _rangeSet = false;
            _tradesToday = 0;
        }

        protected override void OnBarClosed()
        {
            if (Server.Time.Date != _tradeDate)
            {
                _tradesToday = 0;
                _tradeDate = Server.Time.Date;
            }

            if (_tradesToday >= MaxTradesPerDay)
                return;

            if (Server.Time.Date != _sessionDate)
            {
                _sessionDate = Server.Time.Date;
                _rangeSet = false;
            }

            double spread = (Symbol.Ask - Symbol.Bid) / Symbol.PipSize;
            if (spread > MaxSpread)
                return;

            if (!_rangeSet)
                SetOpeningRange();

            double atrValue = _atr.Result.Last(1);
            double entryOffsetPips = EntryOffset * Symbol.PipSize;
            double slPips = atrValue * SL_ATR_Multiplier;
            double tpPips = slPips * TP_Ratio;

            if (!HasPendingOrder(TradeType.Buy))
            {
                double buyStopPrice = _rangeHigh + entryOffsetPips;
                var buyRequest = new StopOrderRequest(TradeType.Buy, Symbol.NormalizeVolumeInUnits(LotSize), buyStopPrice)
                {
                    StopLossPips = slPips / Symbol.PipSize,
                    TakeProfitPips = tpPips / Symbol.PipSize,
                    Label = "GQORB",
                    Comment = "ORB Buy",
                    ExpirationTime = Server.Time.Date.AddDays(1)
                };
                var buyResult = ExecuteStopOrder(buyRequest);
                if (!buyResult.IsSuccessful)
                    Print($"Buy stop failed: {buyResult.Error}");
            }

            if (!HasPendingOrder(TradeType.Sell))
            {
                double sellStopPrice = _rangeLow - entryOffsetPips;
                var sellRequest = new StopOrderRequest(TradeType.Sell, Symbol.NormalizeVolumeInUnits(LotSize), sellStopPrice)
                {
                    StopLossPips = slPips / Symbol.PipSize,
                    TakeProfitPips = tpPips / Symbol.PipSize,
                    Label = "GQORB",
                    Comment = "ORB Sell",
                    ExpirationTime = Server.Time.Date.AddDays(1)
                };
                var sellResult = ExecuteStopOrder(sellRequest);
                if (!sellResult.IsSuccessful)
                    Print($"Sell stop failed: {sellResult.Error}");
            }

            UpdatePanel(atrValue);
        }

        private void SetOpeningRange()
        {
            var bars = Bars.Take(OrbMinutes);
            if (bars.Count() < 2)
                return;

            _rangeHigh = Bars.HighPrices.Maximum(Math.Max(0, Bars.Count - OrbMinutes));
            _rangeLow = Bars.LowPrices.Minimum(Math.Max(0, Bars.Count - OrbMinutes));
            _rangeSet = true;

            Print($"ORB set: High={_rangeHigh}, Low={_rangeLow}");
        }

        private bool HasPendingOrder(TradeType tradeType)
        {
            return PendingOrders.Any(o => o.SymbolName == SymbolName && o.TradeType == tradeType && o.Label == "GQORB");
        }

        protected override void OnPositionOpened(Position position)
        {
            if (position.Label != "GQORB" || position.SymbolName != SymbolName)
                return;

            _tradesToday++;
            Print($"ORB position opened: {position.TradeType}, {position.VolumeInUnits}");
        }

        private void UpdatePanel(double atrValue)
        {
            Chart.DrawStaticText("ORBHigh", $"Range High: {_rangeHigh:F5}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Green);
            Chart.DrawStaticText("ORBLow", $"Range Low: {_rangeLow:F5}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Red);
            Chart.DrawStaticText("ORBATR", $"ATR: {atrValue:F5}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Cyan);
            Chart.DrawStaticText("ORBTrades", $"Trades Today: {_tradesToday}/{MaxTradesPerDay}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Yellow);
            Chart.DrawStaticText("ORBRange", $"Range Set: {_rangeSet}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Orange);
        }
    }
}
