using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Trend_Follower : Robot
    {
        [Parameter("Fast EMA", Group = "EMA", DefaultValue = 20)]
        public int FastEMA { get; set; }

        [Parameter("Slow EMA", Group = "EMA", DefaultValue = 50)]
        public int SlowEMA { get; set; }

        [Parameter("ATR Period", Group = "ATR", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        [Parameter("ATR Multiplier", Group = "ATR", DefaultValue = 2.0)]
        public double ATRMultiplier { get; set; }

        [Parameter("Risk Percent", Group = "Risk", DefaultValue = 2.0)]
        public double RiskPercent { get; set; }

        [Parameter("SuperTrend Period", Group = "SuperTrend", DefaultValue = 10)]
        public int SuperTrendPeriod { get; set; }

        [Parameter("SuperTrend Multiplier", Group = "SuperTrend", DefaultValue = 3.0)]
        public double SuperTrendMultiplier { get; set; }

        [Parameter("Volatility Threshold", Group = "ATR", DefaultValue = 0.0001)]
        public double VolatilityThreshold { get; set; }

        [Parameter("Volume Type", Group = "Risk", DefaultValue = VolumeType.RiskPercent)]
        public VolumeType RiskVolumeType { get; set; }

        [Parameter("Lot Size (Fixed)", Group = "Risk", DefaultValue = 0.01)]
        public double LotSize { get => _lotSize; set => _lotSize = value; }

        private ExponentialMovingAverage _fastEma;
        private ExponentialMovingAverage _slowEma;
        private AverageTrueRange _atr;
        private SuperTrend _superTrend;

        private double _currentATR;
        private int _superTrendTrend;
        private double _lotSize = 0.01;

        protected override void OnStart()
        {
            _fastEma = Indicators.ExponentialMovingAverage(Bars.ClosePrices, FastEMA);
            _slowEma = Indicators.ExponentialMovingAverage(Bars.ClosePrices, SlowEMA);
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _superTrend = Indicators.Supertrend(SuperTrendPeriod, SuperTrendMultiplier);
        }

        protected override void OnBarClosed()
        {
            UpdateIndicators();

            if (_currentATR < VolatilityThreshold)
                return;

            bool isFastAboveSlow = _fastEma.Result.Last(1) > _slowEma.Result.Last(1);
            bool isFastBelowSlow = _fastEma.Result.Last(1) < _slowEma.Result.Last(1);
            bool crossAbove = _fastEma.Result.Last(2) <= _slowEma.Result.Last(2) && isFastAboveSlow;
            bool crossBelow = _fastEma.Result.Last(2) >= _slowEma.Result.Last(2) && isFastBelowSlow;

            if (crossAbove && _superTrendTrend > 0)
            {
                CloseExistingPositions(TradeType.Sell);
                OpenPosition(TradeType.Buy);
            }
            else if (crossBelow && _superTrendTrend < 0)
            {
                CloseExistingPositions(TradeType.Buy);
                OpenPosition(TradeType.Sell);
            }

            UpdatePanel();
        }

        private void UpdateIndicators()
        {
            _currentATR = _atr.Result.Last(1);
            // Supertrend expone UpTrend/DownTrend (no un unico Result)
            double closePrice = Bars.ClosePrices.Last(1);
            bool inUpTrend = closePrice > _superTrend.UpTrend.Last(1) && _superTrend.UpTrend.Last(1) > 0;
            _superTrendTrend = inUpTrend ? 1 : -1;
        }

        private void OpenPosition(TradeType tradeType)
        {
            if (HasExistingPosition(tradeType))
                return;

            double atrSL = _currentATR * ATRMultiplier;
            double atrTP = atrSL * 1.5;

            double volume = RiskVolumeType == VolumeType.RiskPercent
                ? CalculateVolumeByRisk(tradeType, atrSL)
                : Symbol.NormalizeVolumeInUnits(LotSize);

            var request = new MarketOrderRequest(tradeType, volume)
            {
                StopLossPips = atrSL / Symbol.PipSize,
                TakeProfitPips = atrTP / Symbol.PipSize,
                Label = "GQTrend",
                Comment = $"ATR:{_currentATR:F5}"
            };

            var result = ExecuteMarketOrder(request);
            if (!result.IsSuccessful)
                Print($"Order failed: {result.Error}");
        }

        private double CalculateVolumeByRisk(TradeType tradeType, double atrSL)
        {
            double accountRisk = Account.Balance * RiskPercent / 100;
            double pipValue = Symbol.PipValue;
            double slPips = atrSL / Symbol.PipSize;
            double volume = accountRisk / (slPips * pipValue);
            return Symbol.NormalizeVolumeInUnits(volume);
        }

        private bool HasExistingPosition(TradeType tradeType)
        {
            return Positions.Any(p => p.SymbolName == SymbolName && p.TradeType == tradeType && p.Label == "GQTrend");
        }

        private void CloseExistingPositions(TradeType tradeType)
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.TradeType == tradeType && p.Label == "GQTrend").ToArray();
            foreach (var pos in positions)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Close failed: {result.Error}");
            }
        }

        private void UpdatePanel()
        {
            string trendDir = _superTrendTrend > 0 ? "UP" : "DOWN";
            double posSize = Positions.Any(p => p.SymbolName == SymbolName && p.Label == "GQTrend")
                ? Positions.First(p => p.SymbolName == SymbolName && p.Label == "GQTrend").VolumeInUnits
                : 0;

            Chart.DrawStaticText("TrendDir", $"Trend: {trendDir}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Yellow);
            Chart.DrawStaticText("ATRVal", $"ATR: {_currentATR:F5}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Cyan);
            Chart.DrawStaticText("PosSize", $"Size: {posSize}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Orange);
        }

    }

    public enum VolumeType
    {
        RiskPercent,
        FixedLot
    }
}
