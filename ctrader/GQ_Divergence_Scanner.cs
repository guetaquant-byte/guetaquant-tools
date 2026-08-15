//+------------------------------------------------------------------+
//|                                           GQ_Divergence_Scanner.cs |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
using System;
using System.Collections.Generic;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Requests;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class GQ_Divergence_Scanner : Robot
    {
        [Parameter("RSI Period", Group = "RSI", DefaultValue = 14)]
        public int RSIPeriod { get; set; }

        [Parameter("MACD Fast", Group = "MACD", DefaultValue = 12)]
        public int MACDFast { get; set; }

        [Parameter("MACD Slow", Group = "MACD", DefaultValue = 26)]
        public int MACDSlow { get; set; }

        [Parameter("MACD Signal", Group = "MACD", DefaultValue = 9)]
        public int MACDSignal { get; set; }

        [Parameter("Divergence Lookback", Group = "Settings", DefaultValue = 30)]
        public int DivergenceLookback { get; set; }

        [Parameter("Symbols", Group = "Settings", DefaultValue = "EURUSD,GBPUSD,USDJPY,AUDUSD")]
        public string SymbolsToScan { get; set; }

        [Parameter("Auto Trade", Group = "Trade", DefaultValue = false)]
        public bool AutoTrade { get; set; }

        [Parameter("Risk Percent", Group = "Trade", DefaultValue = 1.0)]
        public double RiskPercent { get; set; }

        private List<string> _symbolList;
        private Dictionary<string, DivergenceData> _divergenceData;
        private Dictionary<string, int> _divergenceCount;

        private class DivergenceData
        {
            public RelativeStrengthIndex RSI { get; set; }
            public MacdHistogram MACD { get; set; }
            public List<double> PricePeaks { get; set; }
            public List<double> RsiPeaks { get; set; }
            public List<double> MacdPeaks { get; set; }
            public List<double> PriceValleys { get; set; }
            public List<double> RsiValleys { get; set; }
            public List<double> MacdValleys { get; set; }
        }

        protected override void OnStart()
        {
            _symbolList = (SymbolsToScan ?? "EURUSD,GBPUSD,USDJPY,AUDUSD").Split(',').Select(s => s.Trim()).ToList();
            _divergenceData = new Dictionary<string, DivergenceData>();
            _divergenceCount = new Dictionary<string, int>();

            foreach (var symbol in _symbolList)
            {
                _divergenceData[symbol] = new DivergenceData();
                _divergenceCount[symbol] = 0;
            }
        }

        protected override void OnBarClosed()
        {
            foreach (var symbol in _symbolList)
            {
                ScanSymbol(symbol);
            }

            UpdatePanel();
        }

        private void ScanSymbol(string symbolName)
        {
            var symbol = Symbols.GetSymbol(symbolName);
            if (symbol == null)
                return;

            var data = _divergenceData[symbolName];
            var series = MarketData.GetBars(symbolName, TimeFrame);

            if (data.RSI == null)
            {
                data.RSI = Indicators.RelativeStrengthIndex(series.ClosePrices, RSIPeriod);
                data.MACD = Indicators.MacdHistogram(series.ClosePrices, MACDFast, MACDSlow, MACDSignal);
                data.PricePeaks = new List<double>();
                data.RsiPeaks = new List<double>();
                data.MacdPeaks = new List<double>();
                data.PriceValleys = new List<double>();
                data.RsiValleys = new List<double>();
                data.MacdValleys = new List<double>();
            }

            int bars = Math.Min(DivergenceLookback, series.ClosePrices.Count - 1);
            if (bars < 10)
                return;

            DetectPeaksAndValleys(series, data, bars);

            CheckDivergences(symbolName, symbol, series, data);
        }

        private void DetectPeaksAndValleys(Bars series, DivergenceData data, int bars)
        {
            data.PricePeaks.Clear();
            data.RsiPeaks.Clear();
            data.MacdPeaks.Clear();
            data.PriceValleys.Clear();
            data.RsiValleys.Clear();
            data.MacdValleys.Clear();

            for (int i = 5; i < bars - 5; i++)
            {
                bool pricePeak = true;
                bool priceValley = true;

                for (int j = 1; j <= 2; j++)
                {
                    if (series.HighPrices.Last(i) <= series.HighPrices.Last(i - j) ||
                        series.HighPrices.Last(i) <= series.HighPrices.Last(i + j))
                        pricePeak = false;

                    if (series.LowPrices.Last(i) >= series.LowPrices.Last(i - j) ||
                        series.LowPrices.Last(i) >= series.LowPrices.Last(i + j))
                        priceValley = false;
                }

                double rsiVal = data.RSI.Result.Last(i);
                double macdVal = data.MACD.Histogram.Last(i);

                if (pricePeak)
                {
                    data.PricePeaks.Add(series.HighPrices.Last(i));
                    data.RsiPeaks.Add(rsiVal);
                    data.MacdPeaks.Add(macdVal);
                }

                if (priceValley)
                {
                    data.PriceValleys.Add(series.LowPrices.Last(i));
                    data.RsiValleys.Add(rsiVal);
                    data.MacdValleys.Add(macdVal);
                }
            }
        }

        private void CheckDivergences(string symbolName, Symbol symbol, Bars series, DivergenceData data)
        {
            int count = _divergenceCount[symbolName];

            if (data.PricePeaks.Count >= 2 && data.RsiPeaks.Count >= 2)
            {
                double p1 = data.PricePeaks[data.PricePeaks.Count - 2];
                double p2 = data.PricePeaks[data.PricePeaks.Count - 1];
                double r1 = data.RsiPeaks[data.RsiPeaks.Count - 2];
                double r2 = data.RsiPeaks[data.RsiPeaks.Count - 1];

                if (p2 > p1 && r2 < r1)
                {
                    count++;
                    Print($"Regular RSI Bearish Divergence on {symbolName}");
                    if (AutoTrade) ExecuteDivergenceTrade(symbol, TradeType.Sell, series.ClosePrices.Last(1));
                }
                else if (p2 < p1 && r2 > r1)
                {
                    count++;
                    Print($"Hidden RSI Bullish Divergence on {symbolName}");
                }

                if (data.MacdPeaks.Count >= 2)
                {
                    double m1 = data.MacdPeaks[data.MacdPeaks.Count - 2];
                    double m2 = data.MacdPeaks[data.MacdPeaks.Count - 1];

                    if (p2 > p1 && m2 < m1)
                    {
                        count++;
                        Print($"Regular MACD Bearish Divergence on {symbolName}");
                        if (AutoTrade) ExecuteDivergenceTrade(symbol, TradeType.Sell, series.ClosePrices.Last(1));
                    }
                    else if (p2 < p1 && m2 > m1)
                    {
                        count++;
                        Print($"Hidden MACD Bullish Divergence on {symbolName}");
                    }
                }
            }

            if (data.PriceValleys.Count >= 2 && data.RsiValleys.Count >= 2)
            {
                double p1 = data.PriceValleys[data.PriceValleys.Count - 2];
                double p2 = data.PriceValleys[data.PriceValleys.Count - 1];
                double r1 = data.RsiValleys[data.RsiValleys.Count - 2];
                double r2 = data.RsiValleys[data.RsiValleys.Count - 1];

                if (p2 < p1 && r2 > r1)
                {
                    count++;
                    Print($"Regular RSI Bullish Divergence on {symbolName}");
                    if (AutoTrade) ExecuteDivergenceTrade(symbol, TradeType.Buy, series.ClosePrices.Last(1));
                }
                else if (p2 > p1 && r2 < r1)
                {
                    count++;
                    Print($"Hidden RSI Bearish Divergence on {symbolName}");
                }

                if (data.MacdValleys.Count >= 2)
                {
                    double m1 = data.MacdValleys[data.MacdValleys.Count - 2];
                    double m2 = data.MacdValleys[data.MacdValleys.Count - 1];

                    if (p2 < p1 && m2 > m1)
                    {
                        count++;
                        Print($"Regular MACD Bullish Divergence on {symbolName}");
                        if (AutoTrade) ExecuteDivergenceTrade(symbol, TradeType.Buy, series.ClosePrices.Last(1));
                    }
                    else if (p2 > p1 && m2 < m1)
                    {
                        count++;
                        Print($"Hidden MACD Bearish Divergence on {symbolName}");
                    }
                }
            }

            _divergenceCount[symbolName] = count;
        }

        private void ExecuteDivergenceTrade(Symbol symbol, TradeType tradeType, double entryPrice)
        {
            string label = "GQDivergence";
            if (Positions.Any(p => p.SymbolName == symbol.Name && p.Label == label))
                return;

            double accountRisk = Account.Balance * RiskPercent / 100;
            double slPips = 20;
            double tpPips = 40;
            double pipValue = symbol.PipValue;
            double volume = symbol.NormalizeVolumeInUnits(accountRisk / (slPips * pipValue));

            var request = new MarketOrderRequest(tradeType, volume)
            {
                SymbolName = symbol.Name,
                StopLossPips = slPips,
                TakeProfitPips = tpPips,
                Label = label,
                Comment = "Divergence"
            };

            var result = ExecuteMarketOrder(request);
            if (!result.IsSuccessful)
                Print($"Divergence trade failed on {symbol.Name}: {result.Error}");
        }

        private void UpdatePanel()
        {
            int yOffset = 0;
            foreach (var symbol in _symbolList)
            {
                string text = $"{symbol}: {_divergenceCount[symbol]} divergences";
                Chart.DrawStaticText($"Div_{symbol}", text, VerticalAlignment.Top, HorizontalAlignment.Left, Color.Cyan);
                yOffset += 20;
            }
        }
    }
}
