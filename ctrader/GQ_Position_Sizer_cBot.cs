using System;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQPositionSizerCBot : Robot
    {
        [Parameter("Risk %", DefaultValue = 2.0, MinValue = 0.1, MaxValue = 10.0)]
        public double RiskPercent { get; set; }

        [Parameter("ATR Period", DefaultValue = 14, MinValue = 5)]
        public int AtrPeriod { get; set; }

        [Parameter("ATR Multiplier", DefaultValue = 2.5, MinValue = 0.5)]
        public double AtrMultiplier { get; set; }

        [Parameter("Fixed Stop (points, 0 = use ATR)", DefaultValue = 0.0, MinValue = 0)]
        public double FixedStopPoints { get; set; }

        [Parameter("Show Panel", DefaultValue = true)]
        public bool ShowPanel { get; set; }

        private TrueRange _tr;
        private int _lastBarIndex = -1;
        private TextBlock _panelText;

        protected override void OnStart()
        {
            _tr = Indicators.TrueRange();
            if (ShowPanel) CreatePanel();
            Print("GQ Position Sizer cBot initialized.");
        }

        protected override void OnTick()
        {
            if (Bars.Count < AtrPeriod + 1) return;
            if (Bars.Count == _lastBarIndex) return;
            _lastBarIndex = Bars.Count;

            double stopDistance = GetStopDistance();
            if (stopDistance <= 0) return;

            double balance = Account.Balance;
            double riskMoney = balance * (RiskPercent / 100.0);

            double tickSize = Symbol.TickSize;
            double tickValue = Symbol.TickValue;

            if (tickSize <= 0 || tickValue <= 0) return;

            double stopTicks = stopDistance / tickSize;
            double calculatedLots = stopTicks > 0
                ? riskMoney / (stopTicks * tickValue)
                : 0;

            double minLot = Symbol.VolumeInUnitsMin;
            double maxLot = Symbol.VolumeInUnitsMax;
            double lotStep = Symbol.VolumeInUnitsStep;

            calculatedLots = Math.Floor(calculatedLots / lotStep) * lotStep;
            calculatedLots = Math.Max(calculatedLots, minLot);
            calculatedLots = Math.Min(calculatedLots, maxLot);

            UpdatePanel(balance, riskMoney, stopDistance, calculatedLots);
        }

        private double GetStopDistance()
        {
            if (FixedStopPoints > 0)
                return FixedStopPoints * Symbol.PointSize;

            double atr = CalculateAtr();
            return atr > 0 ? atr * AtrMultiplier : 0;
        }

        private double CalculateAtr()
        {
            double sum = 0;
            for (int i = 0; i < AtrPeriod; i++)
                sum += _tr.Result[i];
            return sum / AtrPeriod;
        }

        private void CreatePanel()
        {
            _panelText = new TextBlock
            {
                Text = "",
                ForegroundColor = Color.White,
                BackgroundColor = Color.FromArgb(200, 20, 20, 20),
                FontSize = 12,
                Padding = new Thickness(8, 6, 8, 6),
                HorizontalAlignment = HorizontalAlignment.Left,
                VerticalAlignment = VerticalAlignment.Top
            };
            Chart.AddControl(_panelText);
        }

        private void UpdatePanel(double balance, double riskMoney, double stopDist, double lots)
        {
            if (!ShowPanel || _panelText == null) return;
            _panelText.Text =
                "GUETA QUANT - POSITION SIZER\n" +
                "━━━━━━━━━━━━━━━━━━━━━━\n" +
                $"Symbol: {Symbol.Name}\n" +
                $"Balance: {balance:F2} USD\n" +
                $"Risk ({RiskPercent:F1}%): {riskMoney:F2} USD\n" +
                $"Stop Dist: {stopDist / Symbol.PointSize:F1} pts\n" +
                "━━━━━━━━━━━━━━━━━━━━━━\n" +
                $"LOT SIZE: {lots:F2}\n" +
                $"Units: {lots * Symbol.VolumeInUnitsStep}\n" +
                "━━━━━━━━━━━━━━━━━━━━━━\n" +
                "Demo use only. Educational.";
        }

        protected override void OnStop()
        {
            Print("GQ Position Sizer cBot stopped.");
        }
    }
}
