using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_DCA_Recovery : Robot
    {
        [Parameter("Entry Spacing ATR", Group = "DCA", DefaultValue = 1.0)]
        public double EntrySpacing_ATR { get; set; }

        [Parameter("Max Levels", Group = "DCA", DefaultValue = 5)]
        public int MaxLevels { get; set; }

        [Parameter("Lot Multiplier", Group = "DCA", DefaultValue = 1.0)]
        public double LotMultiplier { get; set; }

        [Parameter("Basket TP ATR", Group = "Take Profit", DefaultValue = 0.5)]
        public double BasketTP_ATR { get; set; }

        [Parameter("Max Drawdown Percent", Group = "Risk", DefaultValue = 10)]
        public double MaxDrawdown { get; set; }

        [Parameter("Initial Lot Size", Group = "Risk", DefaultValue = 0.01)]
        public double InitialLotSize { get; set; }

        [Parameter("ATR Period", Group = "DCA", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        [Parameter("Trade Direction", Group = "DCA", DefaultValue = TradeDirection.Both)]
        public TradeDirection Direction { get; set; }

        private AverageTrueRange _atr;
        private double _initialEquity;

        protected override void OnStart()
        {
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _initialEquity = Account.Equity;
            UpdatePanel();
        }

        protected override void OnPositionOpened(Position position)
        {
            if (position.Label != "GQDCA" || position.SymbolName != SymbolName)
                return;

            Print($"DCA level {GetRecoveryLevel(position.TradeType)} opened at {position.EntryPrice}");
        }

        protected override void OnTick()
        {
            if (Direction == TradeDirection.None)
                return;

            double currentDrawdown = (_initialEquity - Account.Equity) / _initialEquity * 100;
            if (currentDrawdown > MaxDrawdown)
            {
                CloseAllRecoveryPositions();
                Print($"Max drawdown {MaxDrawdown}% exceeded. Closing all recovery positions.");
                return;
            }

            CheckBasketTakeProfit();
            UpdatePanel();

            if (Direction == TradeDirection.Buy || Direction == TradeDirection.Both)
                EvaluateDCA(TradeType.Buy);

            if (Direction == TradeDirection.Sell || Direction == TradeDirection.Both)
                EvaluateDCA(TradeType.Sell);
        }

        private void EvaluateDCA(TradeType tradeType)
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQDCA" && p.TradeType == tradeType)
                .OrderBy(p => p.EntryPrice)
                .ToArray();

            int currentLevel = positions.Length;
            if (currentLevel >= MaxLevels)
                return;

            double lastEntryPrice;
            double currentPrice = tradeType == TradeType.Buy ? Symbol.Bid : Symbol.Ask;

            if (currentLevel == 0)
            {
                double atrValue = _atr.Result.Last(1);
                double entryOffset = atrValue * EntrySpacing_ATR;
                double entryPrice = tradeType == TradeType.Buy
                    ? currentPrice - entryOffset
                    : currentPrice + entryOffset;

                OpenRecoveryPosition(tradeType, entryPrice, 1);
                return;
            }

            var lastPosition = positions.Last();
            lastEntryPrice = lastPosition.EntryPrice;
            double atrVal = _atr.Result.Last(1);
            double spacing = atrVal * EntrySpacing_ATR;

            bool shouldAdd = tradeType == TradeType.Buy
                ? (Symbol.Bid <= lastEntryPrice - spacing)
                : (Symbol.Ask >= lastEntryPrice + spacing);

            if (shouldAdd)
            {
                double nextLotSize = Symbol.NormalizeVolumeInUnits(InitialLotSize * Math.Pow(LotMultiplier, currentLevel));
                double entryPrice = tradeType == TradeType.Buy
                    ? lastEntryPrice - spacing
                    : lastEntryPrice + spacing;

                OpenRecoveryPosition(tradeType, entryPrice, currentLevel + 1);
            }
        }

        private void OpenRecoveryPosition(TradeType tradeType, double entryPrice, int level)
        {
            double volume = Symbol.NormalizeVolumeInUnits(InitialLotSize * Math.Pow(LotMultiplier, level - 1));

            var request = new LimitOrderRequest(tradeType, volume, entryPrice)
            {
                Label = "GQDCA",
                Comment = $"Level:{level}",
                ExpirationTime = Server.Time.AddDays(7)
            };

            var result = ExecuteLimitOrder(request);
            if (!result.IsSuccessful)
                Print($"DCA entry failed at level {level}: {result.Error}");
        }

        private void CheckBasketTakeProfit()
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQDCA").ToArray();
            if (positions.Length == 0)
                return;

            double totalNetProfit = positions.Sum(p => p.NetProfit);
            double totalVolume = positions.Sum(p => p.VolumeInUnits);
            double avgEntryPrice = positions.Sum(p => p.EntryPrice * p.VolumeInUnits) / totalVolume;
            double atrValue = _atr.Result.Last(1);
            double basketTP = atrValue * BasketTP_ATR;

            double currentPrice = Symbol.Bid;
            double priceDistance = 0;

            if (Direction == TradeDirection.Buy || Direction == TradeDirection.Both)
            {
                var buyPositions = positions.Where(p => p.TradeType == TradeType.Buy).ToArray();
                if (buyPositions.Length > 0)
                {
                    double buyAvg = buyPositions.Sum(p => p.EntryPrice * p.VolumeInUnits) / buyPositions.Sum(p => p.VolumeInUnits);
                    if (Symbol.Bid >= buyAvg + basketTP)
                    {
                        CloseAllRecoveryPositions();
                        Print($"Basket TP hit for buy positions. Profit: {totalNetProfit:F2}");
                        return;
                    }
                }
            }

            if (Direction == TradeDirection.Sell || Direction == TradeDirection.Both)
            {
                var sellPositions = positions.Where(p => p.TradeType == TradeType.Sell).ToArray();
                if (sellPositions.Length > 0)
                {
                    double sellAvg = sellPositions.Sum(p => p.EntryPrice * p.VolumeInUnits) / sellPositions.Sum(p => p.VolumeInUnits);
                    if (Symbol.Ask <= sellAvg - basketTP)
                    {
                        CloseAllRecoveryPositions();
                        Print($"Basket TP hit for sell positions. Profit: {totalNetProfit:F2}");
                        return;
                    }
                }
            }
        }

        private void CloseAllRecoveryPositions()
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQDCA").ToArray();
            foreach (var pos in positions)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Close failed for {pos.Id}: {result.Error}");
            }

            var orders = PendingOrders.Where(o => o.SymbolName == SymbolName && o.Label == "GQDCA").ToArray();
            foreach (var order in orders)
            {
                var result = CancelPendingOrder(order);
                if (!result.IsSuccessful)
                    Print($"Cancel failed for {order.Id}: {result.Error}");
            }
        }

        private int GetRecoveryLevel(TradeType tradeType)
        {
            return Positions.Count(p => p.SymbolName == SymbolName && p.Label == "GQDCA" && p.TradeType == tradeType);
        }

        private void UpdatePanel()
        {
            int buyLevels = Positions.Count(p => p.SymbolName == SymbolName && p.Label == "GQDCA" && p.TradeType == TradeType.Buy);
            int sellLevels = Positions.Count(p => p.SymbolName == SymbolName && p.Label == "GQDCA" && p.TradeType == TradeType.Sell);
            double totalProfit = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQDCA").Sum(p => p.NetProfit);
            double drawdown = (_initialEquity - Account.Equity) / _initialEquity * 100;

            Chart.DrawStaticText("DCABuy", $"Buy Levels: {buyLevels}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Green);
            Chart.DrawStaticText("DCASell", $"Sell Levels: {sellLevels}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Red);
            Chart.DrawStaticText("DCAPnL", $"P&L: {totalProfit:F2}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Cyan);
            Chart.DrawStaticText("DCADD", $"Drawdown: {drawdown:F2}%", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Orange);
        }
    }

    public enum TradeDirection
    {
        None,
        Buy,
        Sell,
        Both
    }
}
