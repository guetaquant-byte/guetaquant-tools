using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Trailing_Stop_Manager : Robot
    {
        [Parameter("Trailing Method", Group = "Trailing", DefaultValue = TrailingMethodType.ATR)]
        public TrailingMethodType TrailingMethod { get; set; }

        [Parameter("Trail Distance ATR", Group = "Trailing", DefaultValue = 1.5)]
        public double TrailDistance_ATR { get; set; }

        [Parameter("Trail Distance Pips", Group = "Trailing", DefaultValue = 20)]
        public double TrailDistance_Pips { get; set; }

        [Parameter("Activation Pips", Group = "Trailing", DefaultValue = 15)]
        public double Activation_Pips { get; set; }

        [Parameter("BE Offset Pips", Group = "Breakeven", DefaultValue = 5)]
        public double BE_Offset_Pips { get; set; }

        [Parameter("Partial Close Level 1 Pct", Group = "Partial Close", DefaultValue = 50)]
        public double PartialClose_Pct1 { get; set; }

        [Parameter("Partial Close Level 1 RR", Group = "Partial Close", DefaultValue = 1.0)]
        public double PartialClose_RR1 { get; set; }

        [Parameter("Partial Close Level 2 Pct", Group = "Partial Close", DefaultValue = 25)]
        public double PartialClose_Pct2 { get; set; }

        [Parameter("Partial Close Level 2 RR", Group = "Partial Close", DefaultValue = 2.0)]
        public double PartialClose_RR2 { get; set; }

        [Parameter("ATR Period", Group = "ATR", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        [Parameter("Parabolic SAR Step", Group = "Parabolic SAR", DefaultValue = 0.02)]
        public double ParabolicStep { get; set; }

        [Parameter("Parabolic SAR Max", Group = "Parabolic SAR", DefaultValue = 0.2)]
        public double ParabolicMax { get; set; }

        private AverageTrueRange _atr;
        private ParabolicSAR _psar;
        private double _fractalValue;

        protected override void OnStart()
        {
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _psar = Indicators.ParabolicSAR(ParabolicStep, ParabolicMax);
        }

        protected override void OnTick()
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.Label.StartsWith("GQ")).ToArray();

            foreach (var pos in positions)
            {
                double currentPrice = pos.TradeType == TradeType.Buy ? Symbol.Bid : Symbol.Ask;
                double entryPrice = pos.EntryPrice;
                double pipsDistance = Math.Abs(currentPrice - entryPrice) / Symbol.PipSize;
                double grossProfit = pos.GrossProfit;

                if (pipsDistance >= BE_Offset_Pips && pos.StopLoss != null)
                {
                    double beStopLoss = pos.TradeType == TradeType.Buy
                        ? entryPrice + BE_Offset_Pips * Symbol.PipSize
                        : entryPrice - BE_Offset_Pips * Symbol.PipSize;

                    if ((pos.TradeType == TradeType.Buy && pos.StopLoss.Value < beStopLoss) ||
                        (pos.TradeType == TradeType.Sell && pos.StopLoss.Value > beStopLoss))
                    {
                    UpdatePositionModify(pos, beStopLoss, pos.TakeProfit);
                    Print($"BE set for {pos.Id}");
                    }
                }

                if (pipsDistance >= Activation_Pips)
                {
                    double trailStopLoss = CalculateTrailStop(pos, currentPrice);

                    if ((pos.TradeType == TradeType.Buy && trailStopLoss > pos.StopLoss) ||
                        (pos.TradeType == TradeType.Sell && trailStopLoss < pos.StopLoss))
                    {
                        UpdatePositionModify(pos, trailStopLoss, pos.TakeProfit);
                        Print($"Trailing updated for {pos.Id}");
                    }
                }

                HandlePartialClose(pos, entryPrice, grossProfit);
            }
        }

        private double CalculateTrailStop(Position pos, double currentPrice)
        {
            double atrValue = _atr.Result.Last(1);

            switch (TrailingMethod)
            {
                case TrailingMethodType.ATR:
                    double atrDist = atrValue * TrailDistance_ATR;
                    return pos.TradeType == TradeType.Buy
                        ? currentPrice - atrDist
                        : currentPrice + atrDist;

                case TrailingMethodType.FixedPips:
                    double pipDist = TrailDistance_Pips * Symbol.PipSize;
                    return pos.TradeType == TradeType.Buy
                        ? currentPrice - pipDist
                        : currentPrice + pipDist;

                case TrailingMethodType.ParabolicSAR:
                    double sar = _psar.Result.Last(1);
                    return sar;

                case TrailingMethodType.Fractal:
                    double fractalStop = FindFractalStop(pos.TradeType);
                    return fractalStop > 0 ? fractalStop : (pos.TradeType == TradeType.Buy
                        ? currentPrice - atrValue * TrailDistance_ATR
                        : currentPrice + atrValue * TrailDistance_ATR);

                default:
                    return pos.TradeType == TradeType.Buy
                        ? currentPrice - atrValue * TrailDistance_ATR
                        : currentPrice + atrValue * TrailDistance_ATR;
            }
        }

        private double FindFractalStop(TradeType tradeType)
        {
            int lookback = 20;
            int bars = Math.Min(lookback, Bars.Count - 1);

            if (tradeType == TradeType.Buy)
            {
                for (int i = 2; i < bars; i++)
                {
                    if (Bars.LowPrices.Last(i) < Bars.LowPrices.Last(i - 1) &&
                        Bars.LowPrices.Last(i) < Bars.LowPrices.Last(i + 1))
                    {
                        return Bars.LowPrices.Last(i);
                    }
                }
            }
            else
            {
                for (int i = 2; i < bars; i++)
                {
                    if (Bars.HighPrices.Last(i) > Bars.HighPrices.Last(i - 1) &&
                        Bars.HighPrices.Last(i) > Bars.HighPrices.Last(i + 1))
                    {
                        return Bars.HighPrices.Last(i);
                    }
                }
            }

            return 0;
        }

        private void HandlePartialClose(Position pos, double entryPrice, double grossProfit)
        {
            double pipsDistance = Math.Abs(pos.TradeType == TradeType.Buy ? Symbol.Bid - entryPrice : Symbol.Ask - entryPrice);
            double rrRatio = pipsDistance / (Math.Abs((double)(pos.StopLoss.HasValue ? Math.Abs(entryPrice - pos.StopLoss.Value) : 10 * Symbol.PipSize)));

            if (rrRatio >= PartialClose_RR1 && PartialClose_Pct1 > 0)
            {
                double closeVolume = Symbol.NormalizeVolumeInUnits(pos.VolumeInUnits * PartialClose_Pct1 / 100);
                if (closeVolume > 0 && closeVolume < pos.VolumeInUnits)
                {
                    var result = ClosePosition(pos, closeVolume);
                    if (result.IsSuccessful)
                        Print($"Partial close {PartialClose_Pct1}% at {rrRatio:F2}RR for {pos.Id}");
                }
            }

            if (rrRatio >= PartialClose_RR2 && PartialClose_Pct2 > 0)
            {
                var updatedPos = Positions.FirstOrDefault(p => p.Id == pos.Id);
                if (updatedPos != null)
                {
                    double closeVolume = Symbol.NormalizeVolumeInUnits(updatedPos.VolumeInUnits * PartialClose_Pct2 / 100);
                    if (closeVolume > 0 && closeVolume < updatedPos.VolumeInUnits)
                    {
                        var result = ClosePosition(updatedPos, closeVolume);
                        if (result.IsSuccessful)
                            Print($"Partial close {PartialClose_Pct2}% at {rrRatio:F2}RR for {pos.Id}");
                    }
                }
            }
        }

        private void UpdatePositionModify(Position pos, double? stopLoss, double? takeProfit)
        {
            var result = ModifyPosition(pos, stopLoss, takeProfit);
            if (!result.IsSuccessful)
                Print($"Modify failed for {pos.Id}: {result.Error}");
        }
    }

    public enum TrailingMethodType
    {
        ATR,
        FixedPips,
        ParabolicSAR,
        Fractal
    }
}
