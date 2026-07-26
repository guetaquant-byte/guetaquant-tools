using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Mean_Reversion : Robot
    {
        [Parameter("BB Period", Group = "Bollinger", DefaultValue = 20)]
        public int BBPeriod { get; set; }

        [Parameter("BB StdDev", Group = "Bollinger", DefaultValue = 2.0)]
        public double BBStdDev { get; set; }

        [Parameter("RSI Period", Group = "RSI", DefaultValue = 14)]
        public int RSIPeriod { get; set; }

        [Parameter("RSI Oversold", Group = "RSI", DefaultValue = 30)]
        public int RSIOversold { get; set; }

        [Parameter("RSI Overbought", Group = "RSI", DefaultValue = 70)]
        public int RSIOverbought { get; set; }

        [Parameter("Risk Percent", Group = "Risk", DefaultValue = 1.0)]
        public double RiskPercent { get; set; }

        [Parameter("Volume Multiplier", Group = "Filter", DefaultValue = 1.5)]
        public double VolumeMultiplier { get; set; }

        [Parameter("SL ATR Multiplier", Group = "Risk", DefaultValue = 2.0)]
        public double SL_ATR_Multiplier { get; set; }

        [Parameter("ATR Period", Group = "Risk", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        private BollingerBands _bb;
        private RelativeStrengthIndex _rsi;
        private AverageTrueRange _atr;
        private ExponentialMovingAverage _volumeSma;

        protected override void OnStart()
        {
            _bb = Indicators.BollingerBands(Bars.ClosePrices, BBPeriod, BBStdDev, MovingAverageType.Simple);
            _rsi = Indicators.RelativeStrengthIndex(Bars.ClosePrices, RSIPeriod);
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _volumeSma = Indicators.ExponentialMovingAverage(Bars.TickVolumes, BBPeriod);
        }

        protected override void OnBarClosed()
        {
            double closePrice = Bars.ClosePrices.Last(1);
            double upperBand = _bb.Top.Last(1);
            double lowerBand = _bb.Bottom.Last(1);
            double middleBand = _bb.Middle.Last(1);
            double rsiValue = _rsi.Result.Last(1);
            double volume = Bars.TickVolumes.Last(1);
            double avgVolume = _volumeSma.Result.Last(1);
            double atrValue = _atr.Result.Last(1);

            bool volumeConfirmed = volume > avgVolume * VolumeMultiplier;

            if (!volumeConfirmed)
                return;

            if (closePrice >= upperBand && rsiValue >= RSIOverbought)
            {
                if (!HasPosition(TradeType.Sell))
                {
                    CloseExistingPosition(TradeType.Buy);
                    OpenReversalPosition(TradeType.Sell, closePrice, upperBand, lowerBand, middleBand, atrValue);
                }
            }
            else if (closePrice <= lowerBand && rsiValue <= RSIOversold)
            {
                if (!HasPosition(TradeType.Buy))
                {
                    CloseExistingPosition(TradeType.Sell);
                    OpenReversalPosition(TradeType.Buy, closePrice, upperBand, lowerBand, middleBand, atrValue);
                }
            }
        }

        private void OpenReversalPosition(TradeType tradeType, double entryPrice, double upperBand, double lowerBand, double middleBand, double atrValue)
        {
            double slPrice, tpPrice;

            if (tradeType == TradeType.Buy)
            {
                slPrice = lowerBand - atrValue * SL_ATR_Multiplier;
                tpPrice = middleBand;
            }
            else
            {
                slPrice = upperBand + atrValue * SL_ATR_Multiplier;
                tpPrice = middleBand;
            }

            double slPips = Math.Abs(entryPrice - slPrice) / Symbol.PipSize;
            double tpPips = Math.Abs(entryPrice - tpPrice) / Symbol.PipSize;

            double accountRisk = Account.Balance * RiskPercent / 100;
            double pipValue = Symbol.PipValue;
            double volume = Symbol.NormalizeVolumeInUnits(accountRisk / (slPips * pipValue));

            var request = new MarketOrderRequest(tradeType, volume)
            {
                StopLossPips = slPips,
                TakeProfitPips = tpPips,
                Label = "GQMeanRev",
                Comment = $"RSI:{_rsi.Result.Last(1):F0}"
            };

            var result = ExecuteMarketOrder(request);
            if (!result.IsSuccessful)
                Print($"Order failed: {result.Error}");
        }

        private bool HasPosition(TradeType tradeType)
        {
            return Positions.Any(p => p.SymbolName == SymbolName && p.TradeType == tradeType && p.Label == "GQMeanRev");
        }

        private void CloseExistingPosition(TradeType tradeType)
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.TradeType == tradeType && p.Label == "GQMeanRev").ToArray();
            foreach (var pos in positions)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Close failed: {result.Error}");
            }
        }
    }
}
