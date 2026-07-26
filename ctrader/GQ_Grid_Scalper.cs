using System;
using System.Collections.Generic;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Grid_Scalper : Robot
    {
        [Parameter("Grid Spacing ATR", Group = "Grid", DefaultValue = 0.5)]
        public double GridSpacing_ATR { get; set; }

        [Parameter("Grid Levels", Group = "Grid", DefaultValue = 5)]
        public int GridLevels { get; set; }

        [Parameter("Lot Size", Group = "Risk", DefaultValue = 0.01)]
        public double LotSize { get; set; }

        [Parameter("Max Drawdown Percent", Group = "Risk", DefaultValue = 5)]
        public double MaxDrawdownPercent { get; set; }

        [Parameter("Max Spread", Group = "Filter", DefaultValue = 15)]
        public double MaxSpread { get; set; }

        [Parameter("ATR Period", Group = "Grid", DefaultValue = 14)]
        public int ATRPeriod { get; set; }

        [Parameter("Grid Refresh Bars", Group = "Grid", DefaultValue = 5)]
        public int GridRefreshBars { get; set; }

        private AverageTrueRange _atr;
        private int _barsSinceRefresh;
        private List<double> _buyLevels;
        private List<double> _sellLevels;
        private double _startingEquity;

        protected override void OnStart()
        {
            _atr = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Simple);
            _barsSinceRefresh = 0;
            _buyLevels = new List<double>();
            _sellLevels = new List<double>();
            _startingEquity = Account.Equity;
        }

        protected override void OnBarClosed()
        {
            double spread = (Symbol.Ask - Symbol.Bid) / Symbol.PipSize;
            if (spread > MaxSpread)
                return;

            double currentDrawdown = (Account.Equity - _startingEquity) / _startingEquity * 100;
            if (currentDrawdown < -MaxDrawdownPercent)
            {
                CloseAllGridPositions();
                Print($"Max drawdown reached. Closing all positions.");
                return;
            }

            _barsSinceRefresh++;

            if (_barsSinceRefresh >= GridRefreshBars)
            {
                CancelAllGridOrders();
                _barsSinceRefresh = 0;
                _buyLevels.Clear();
                _sellLevels.Clear();
                DeployGrid();
            }

            ManageExistingPositions();
            UpdatePanel(currentDrawdown);
        }

        private void DeployGrid()
        {
            double atrValue = _atr.Result.Last(1);
            double gridSpacing = atrValue * GridSpacing_ATR;
            double currentPrice = Symbol.Bid;
            double volume = Symbol.NormalizeVolumeInUnits(LotSize);

            double halfRange = (GridLevels / 2) * gridSpacing;
            double centerBuy = currentPrice - gridSpacing * 0.5;
            double centerSell = currentPrice + gridSpacing * 0.5;

            for (int i = 0; i < GridLevels; i++)
            {
                double buyPrice = centerBuy - i * gridSpacing;
                double sellPrice = centerSell + i * gridSpacing;

                if (buyPrice > 0 && !HasOrderNearPrice(TradeType.Buy, buyPrice, gridSpacing * 0.5))
                {
                    var buyRequest = new LimitOrderRequest(TradeType.Buy, volume, buyPrice)
                    {
                        Label = "GQGrid",
                        Comment = $"Level:{i + 1}",
                        ExpirationTime = Server.Time.AddDays(1)
                    };
                    var buyResult = ExecuteLimitOrder(buyRequest);
                    if (buyResult.IsSuccessful)
                        _buyLevels.Add(buyPrice);
                }

                if (sellPrice > 0 && !HasOrderNearPrice(TradeType.Sell, sellPrice, gridSpacing * 0.5))
                {
                    var sellRequest = new LimitOrderRequest(TradeType.Sell, volume, sellPrice)
                    {
                        Label = "GQGrid",
                        Comment = $"Level:{i + 1}",
                        ExpirationTime = Server.Time.AddDays(1)
                    };
                    var sellResult = ExecuteLimitOrder(sellRequest);
                    if (sellResult.IsSuccessful)
                        _sellLevels.Add(sellPrice);
                }
            }
        }

        private bool HasOrderNearPrice(TradeType tradeType, double price, double tolerance)
        {
            bool pendingNear = PendingOrders.Any(o =>
                o.SymbolName == SymbolName &&
                o.TradeType == tradeType &&
                o.Label == "GQGrid" &&
                Math.Abs(o.TargetPrice - price) < tolerance);

            bool positionNear = Positions.Any(p =>
                p.SymbolName == SymbolName &&
                p.TradeType == tradeType &&
                p.Label == "GQGrid" &&
                Math.Abs(p.EntryPrice - price) < tolerance);

            return pendingNear || positionNear;
        }

        private void ManageExistingPositions()
        {
            double atrValue = _atr.Result.Last(1);
            double gridSpacing = atrValue * GridSpacing_ATR;

            var gridPositions = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQGrid").ToArray();

            foreach (var pos in gridPositions)
            {
                double targetPrice = pos.TradeType == TradeType.Buy
                    ? pos.EntryPrice + gridSpacing
                    : pos.EntryPrice - gridSpacing;

                if (pos.TradeType == TradeType.Buy && Symbol.Bid >= targetPrice)
                {
                    var result = ClosePosition(pos);
                    if (!result.IsSuccessful)
                        Print($"Grid TP close failed: {result.Error}");
                }
                else if (pos.TradeType == TradeType.Sell && Symbol.Ask <= targetPrice)
                {
                    var result = ClosePosition(pos);
                    if (!result.IsSuccessful)
                        Print($"Grid TP close failed: {result.Error}");
                }
            }
        }

        private void CancelAllGridOrders()
        {
            var orders = PendingOrders.Where(o => o.SymbolName == SymbolName && o.Label == "GQGrid").ToArray();
            foreach (var order in orders)
            {
                var result = CancelPendingOrder(order);
                if (!result.IsSuccessful)
                    Print($"Cancel order failed: {result.Error}");
            }
        }

        private void CloseAllGridPositions()
        {
            var positions = Positions.Where(p => p.SymbolName == SymbolName && p.Label == "GQGrid").ToArray();
            foreach (var pos in positions)
            {
                var result = ClosePosition(pos);
                if (!result.IsSuccessful)
                    Print($"Emergency close failed: {result.Error}");
            }
        }

        private void UpdatePanel(double drawdown)
        {
            int activePositions = Positions.Count(p => p.SymbolName == SymbolName && p.Label == "GQGrid");
            int activeOrders = PendingOrders.Count(o => o.SymbolName == SymbolName && o.Label == "GQGrid");

            Chart.DrawStaticText("GridPos", $"Positions: {activePositions}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Cyan);
            Chart.DrawStaticText("GridOrd", $"Orders: {activeOrders}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Yellow);
            Chart.DrawStaticText("GridDD", $"Drawdown: {drawdown:F2}%", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Orange);
            Chart.DrawStaticText("GridLevels", $"Levels: {_buyLevels.Count + _sellLevels.Count}", VerticalAlignment.Top, HorizontalAlignment.Left, Color.Magenta);
        }
    }
}
