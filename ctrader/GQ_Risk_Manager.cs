using System;
using System.Collections.Generic;
using System.Linq;
using cAlgo.API;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Risk_Manager : Robot
    {
        [Parameter("Daily Loss Limit Percent", Group = "Risk Limits", DefaultValue = 3)]
        public double DailyLossLimit_Percent { get; set; }

        [Parameter("Max Drawdown Percent", Group = "Risk Limits", DefaultValue = 10)]
        public double MaxDrawdown_Percent { get; set; }

        [Parameter("Max Correlation", Group = "Risk Limits", DefaultValue = 0.7)]
        public double MaxCorrelation { get; set; }

        [Parameter("Max Positions", Group = "Risk Limits", DefaultValue = 5)]
        public int MaxPositions { get; set; }

        [Parameter("Max Lots Total", Group = "Risk Limits", DefaultValue = 1.0)]
        public double MaxLotsTotal { get; set; }

        [Parameter("Check Interval Minutes", Group = "Settings", DefaultValue = 5)]
        public int CheckIntervalMinutes { get; set; }

        [Parameter("Auto Reduce Position Size", Group = "Risk Controls", DefaultValue = true)]
        public bool AutoReducePositionSize { get; set; }

        private double _initialEquity;
        private DateTime _lastCheckTime;
        private double _dailyStartingEquity;
        private DateTime _dailyResetDate;
        private Dictionary<string, List<string>> _correlationGroups;

        protected override void OnStart()
        {
            _initialEquity = Account.Equity;
            _dailyStartingEquity = Account.Equity;
            _dailyResetDate = Server.Time.Date;
            _lastCheckTime = Server.Time;

            _correlationGroups = new Dictionary<string, List<string>>
            {
                { "EURUSD", new List<string> { "GBPUSD", "EURGBP", "EURJPY" } },
                { "GBPUSD", new List<string> { "EURUSD", "GBPJPY", "EURGBP" } },
                { "USDJPY", new List<string> { "EURJPY", "GBPJPY", "USDCAD" } },
                { "AUDUSD", new List<string> { "NZDUSD", "AUDJPY", "AUDCAD" } },
                { "XAUUSD", new List<string> { "XAGUSD", "USDJPY" } }
            };

            UpdatePanel();
        }

        protected override void OnTick()
        {
            if ((Server.Time - _lastCheckTime).TotalMinutes < CheckIntervalMinutes)
                return;

            _lastCheckTime = Server.Time;

            if (Server.Time.Date != _dailyResetDate)
            {
                _dailyStartingEquity = Account.Equity;
                _dailyResetDate = Server.Time.Date;
            }

            CheckDailyLossLimit();
            CheckDrawdownLimit();
            CheckTotalPositionLimits();
            CheckCorrelationExposure();
            ApplyRiskReduction();

            UpdatePanel();
        }

        private void CheckDailyLossLimit()
        {
            double dailyPL = Account.Equity - _dailyStartingEquity;
            double dailyLossPercent = dailyPL / _dailyStartingEquity * 100;

            if (dailyLossPercent <= -DailyLossLimit_Percent)
            {
                Print($"Daily loss limit reached: {dailyLossPercent:F2}%. Closing all positions.");
                CloseAllPositions();
            }
        }

        private void CheckDrawdownLimit()
        {
            double drawdown = (_initialEquity - Account.Equity) / _initialEquity * 100;

            if (drawdown >= MaxDrawdown_Percent)
            {
                Print($"Max drawdown reached: {drawdown:F2}%. Closing all positions.");
                CloseAllPositions();
            }
        }

        private void CheckTotalPositionLimits()
        {
            int totalPositions = Positions.Count;
            if (totalPositions > MaxPositions)
            {
                Print($"Position limit exceeded: {totalPositions}/{MaxPositions}. Reducing positions.");
                ReduceExcessPositions(totalPositions - MaxPositions);
            }

            double totalLots = Positions.Sum(p => p.VolumeInUnits) / 100000.0;
            if (totalLots > MaxLotsTotal)
            {
                Print($"Lot limit exceeded: {totalLots:F2}/{MaxLotsTotal}. Reducing volume.");
                ReduceExcessVolume(totalLots - MaxLotsTotal);
            }
        }

        private void CheckCorrelationExposure()
        {
            foreach (var group in _correlationGroups)
        {
                string baseSymbol = group.Key;
                var correlatedSymbols = group.Value;

                bool hasBase = Positions.Any(p => p.SymbolName == baseSymbol);
                if (!hasBase)
                    continue;

                double correlationExposure = 0;
                foreach (var pos in Positions)
                {
                    if (correlatedSymbols.Contains(pos.SymbolName))
                    {
                        correlationExposure += pos.VolumeInUnits / 100000.0;
                    }
                }

                double baseVolume = Positions
                    .Where(p => p.SymbolName == baseSymbol)
                    .Sum(p => p.VolumeInUnits) / 100000.0;

                double totalCorrelated = baseVolume + correlationExposure;

                if (correlationExposure > 0 && totalCorrelated > MaxLotsTotal * MaxCorrelation)
                {
                    Print($"Correlation limit exceeded for {baseSymbol} group. Reducing correlated positions.");
                    foreach (var pos in Positions.Where(p => correlatedSymbols.Contains(p.SymbolName)).OrderBy(p => Math.Abs(p.NetProfit)))
                    {
                        var result = ClosePosition(pos);
                        if (result.IsSuccessful)
                            Print($"Closed correlated position {pos.SymbolName} {pos.Id}");
                    }
                }
            }
        }

        private void ApplyRiskReduction()
        {
            if (!AutoReducePositionSize)
                return;

            double totalLots = Positions.Sum(p => p.VolumeInUnits) / 100000.0;
            double utilization = totalLots / MaxLotsTotal;

            if (utilization > 0.8)
            {
                double drawdown = (_initialEquity - Account.Equity) / _initialEquity * 100;
                double reductionFactor = 1.0 - (drawdown / MaxDrawdown_Percent);

                if (reductionFactor < 0.8)
                {
                    Print($"Risk reduction active: utilization {utilization:P1}, drawdown {drawdown:F1}%");

                    foreach (var pos in Positions)
                    {
                        double targetVolume = pos.VolumeInUnits * reductionFactor;
                        double reduceBy = pos.VolumeInUnits - Symbol.NormalizeVolumeInUnits(targetVolume);

                        if (reduceBy > Symbol.VolumeInUnitsMin)
                        {
                            var result = ClosePosition(pos, reduceBy);
                            if (result.IsSuccessful)
                                Print($"Reduced {pos.SymbolName} {pos.Id} by {reduceBy}");
                        }
                    }
                }
            }
        }

        private void ReduceExcessPositions(int excessCount)
        {
            var positionsToClose = Positions
                .OrderBy(p => Math.Abs(p.NetProfit))
                .ThenByDescending(p => p.Pips)
                .Take(excessCount)
                .ToArray();

            foreach (var pos in positionsToClose)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Failed to close {pos.Id}: {result.Error}");
            }
        }

        private void ReduceExcessVolume(double excessLots)
        {
            double excessUnits = excessLots * 100000;
            var positions = Positions.OrderBy(p => Math.Abs(p.NetProfit)).ToArray();

            foreach (var pos in positions)
            {
                if (excessUnits <= 0)
                    break;

                double reduceAmount = Math.Min(pos.VolumeInUnits, excessUnits);
                var result = ClosePosition(pos, Symbol.NormalizeVolumeInUnits(reduceAmount));
                if (result.IsSuccessful)
                {
                    excessUnits -= reduceAmount;
                    Print($"Reduced {pos.SymbolName} {pos.Id} by {reduceAmount}");
                }
            }
        }

        private void CloseAllPositions()
        {
            var positions = Positions.ToArray();
            foreach (var pos in positions)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Failed to close {pos.Id}: {result.Error}");
            }
        }

        private void UpdatePanel()
        {
            double totalPL = Positions.Sum(p => p.NetProfit);
            double dailyPL = Account.Equity - _dailyStartingEquity;
            double dailyPLPercent = dailyPL / _dailyStartingEquity * 100;
            double drawdown = (_initialEquity - Account.Equity) / _initialEquity * 100;
            int totalPos = Positions.Count;
            double totalLots = Positions.Sum(p => p.VolumeInUnits) / 100000.0;

            Chart.DrawStaticText("RiskPos", $"Positions: {totalPos}/{MaxPositions}", VerticalAlignment.Top, HorizontalAlignment.Left, totalPos > MaxPositions ? Color.Red : Color.Green);
            Chart.DrawStaticText("RiskLots", $"Lots: {totalLots:F2}/{MaxLotsTotal}", VerticalAlignment.Top, HorizontalAlignment.Left, totalLots > MaxLotsTotal ? Color.Red : Color.Green);
            Chart.DrawStaticText("RiskDaily", $"Daily P&L: {dailyPLPercent:F2}%/{DailyLossLimit_Percent}%", VerticalAlignment.Top, HorizontalAlignment.Left, dailyPLPercent < -DailyLossLimit_Percent ? Color.Red : Color.Cyan);
            Chart.DrawStaticText("RiskDD", $"Drawdown: {drawdown:F2}%/{MaxDrawdown_Percent}%", VerticalAlignment.Top, HorizontalAlignment.Left, drawdown > MaxDrawdown_Percent * 0.8 ? Color.Orange : Color.Yellow);
            Chart.DrawStaticText("RiskPnL", $"Total P&L: ${totalPL:F2}", VerticalAlignment.Top, HorizontalAlignment.Left, totalPL >= 0 ? Color.Green : Color.Red);
        }
    }
}
