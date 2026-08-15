//+------------------------------------------------------------------+
//|                                           GQ_Multi_Symbol_Scanner.cs |
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
    public class GQ_Multi_Symbol_Scanner : Robot
    {
        [Parameter("Symbols", Group = "Settings", DefaultValue = "EURUSD,GBPUSD,USDJPY,AUDUSD,XAUUSD")]
        public string SymbolsToScan { get; set; }

        [Parameter("MA Period", Group = "Indicators", DefaultValue = 200)]
        public int MAPeriod { get; set; }

        [Parameter("RSI Period", Group = "Indicators", DefaultValue = 14)]
        public int RSIPeriod { get; set; }

        [Parameter("BB Period", Group = "Indicators", DefaultValue = 20)]
        public int BBPeriod { get; set; }

        [Parameter("Score Threshold", Group = "Scoring", DefaultValue = 3)]
        public int ScoreThreshold { get; set; }

        [Parameter("Auto Trade Top N", Group = "Trade", DefaultValue = 0)]
        public int AutoTradeTopN { get; set; }

        [Parameter("Lot Size", Group = "Trade", DefaultValue = 0.1)]
        public double LotSize { get; set; }

        [Parameter("SL ATR Multiplier", Group = "Trade", DefaultValue = 1.5)]
        public double SL_ATR { get; set; }

        [Parameter("TP Ratio", Group = "Trade", DefaultValue = 2.0)]
        public double TP_Ratio { get; set; }

        private List<string> _symbolList;
        private Dictionary<string, SymbolScore> _scores;
        private Dictionary<string, IndicatorSet> _indicators;

        private class SymbolScore
        {
            public int BullishScore { get; set; }
            public int BearishScore { get; set; }
            public int TotalScore { get; set; }
            public string Signal { get; set; }
            public double RSI { get; set; }
            public double BB_Position { get; set; }
            public double MA_Distance { get; set; }
        }

        private class IndicatorSet
        {
            public ExponentialMovingAverage MA { get; set; }
            public RelativeStrengthIndex RSI { get; set; }
            public BollingerBands BB { get; set; }
            public AverageTrueRange ATR { get; set; }
            public Bars Series { get; set; }
            public Symbol Symbol { get; set; }
        }

        protected override void OnStart()
        {
            _symbolList = (SymbolsToScan ?? "EURUSD,GBPUSD,USDJPY,AUDUSD,XAUUSD").Split(',').Select(s => s.Trim()).ToList();
            _scores = new Dictionary<string, SymbolScore>();
            _indicators = new Dictionary<string, IndicatorSet>();

            foreach (var symbolName in _symbolList)
            {
                var symbol = Symbols.GetSymbol(symbolName);
                if (symbol == null)
                {
                    Print($"Symbol {symbolName} not found. Skipping.");
                    continue;
                }

                var series = MarketData.GetBars(symbolName, TimeFrame);
                var indicatorSet = new IndicatorSet
                {
                    MA = Indicators.ExponentialMovingAverage(series.ClosePrices, MAPeriod),
                    RSI = Indicators.RelativeStrengthIndex(series.ClosePrices, RSIPeriod),
                    BB = Indicators.BollingerBands(series.ClosePrices, BBPeriod, 2.0, MovingAverageType.Simple),
                    ATR = Indicators.AverageTrueRange(14, MovingAverageType.Simple),
                    Series = series,
                    Symbol = symbol
                };
                _indicators[symbolName] = indicatorSet;
                _scores[symbolName] = new SymbolScore();
            }
        }

        protected override void OnBarClosed()
        {
            foreach (var symbolName in _symbolList)
            {
                if (!_indicators.ContainsKey(symbolName))
                    continue;

                AnalyzeSymbol(symbolName);
            }

            var ranked = GetRankedList();
            DisplayLeaderboard(ranked);

            if (AutoTradeTopN > 0)
                AutoTrade(ranked);
        }

        private void AnalyzeSymbol(string symbolName)
        {
            var ind = _indicators[symbolName];
            var score = _scores[symbolName];

            if (ind.Series.ClosePrices.Count < MAPeriod + 10)
                return;

            double closePrice = ind.Series.ClosePrices.Last(1);
            double maValue = ind.MA.Result.Last(1);
            double rsiValue = ind.RSI.Result.Last(1);
            double upperBB = ind.BB.Top.Last(1);
            double lowerBB = ind.BB.Bottom.Last(1);
            double middleBB = ind.BB.Middle.Last(1);

            score.RSI = rsiValue;
            score.MA_Distance = (closePrice - maValue) / maValue * 100;
            score.BB_Position = (closePrice - lowerBB) / (upperBB - lowerBB);

            int bullish = 0;
            int bearish = 0;

            if (closePrice > maValue) bullish++; else bearish++;
            if (closePrice > middleBB) bullish++; else bearish++;
            if (rsiValue > 50) bullish++; else bearish++;
            if (rsiValue < 30) bullish += 2;
            if (rsiValue > 70) bearish += 2;
            if (closePrice >= upperBB * 0.98) bearish++;
            if (closePrice <= lowerBB * 1.02) bullish++;

            double priceChange = (closePrice - ind.Series.ClosePrices.Last(BBPeriod)) / ind.Series.ClosePrices.Last(BBPeriod) * 100;
            if (priceChange > 0) bullish++; else bearish++;

            score.BullishScore = bullish;
            score.BearishScore = bearish;
            score.TotalScore = bullish - bearish;

            if (score.TotalScore >= ScoreThreshold)
                score.Signal = "BULLISH";
            else if (score.TotalScore <= -ScoreThreshold)
                score.Signal = "BEARISH";
            else
                score.Signal = "NEUTRAL";
        }

        private List<KeyValuePair<string, SymbolScore>> GetRankedList()
        {
            return _scores
                .Where(s => s.Value != null)
                .OrderByDescending(s => Math.Abs(s.Value.TotalScore))
                .ThenByDescending(s => s.Value.TotalScore)
                .ToList();
        }

        private void DisplayLeaderboard(List<KeyValuePair<string, SymbolScore>> ranked)
        {
            int pos = 0;
            foreach (var entry in ranked)
            {
                var score = entry.Value;
                Color color = score.TotalScore >= ScoreThreshold ? Color.Green :
                              score.TotalScore <= -ScoreThreshold ? Color.Red : Color.Gray;

                string text = $"{pos + 1}. {entry.Key}: {score.TotalScore:+0;-0} ({score.Signal}) RSI:{score.RSI:F0}";
                Chart.DrawStaticText($"Rank_{pos}", text, VerticalAlignment.Top, HorizontalAlignment.Left, color);
                pos++;
            }
        }

        private void AutoTrade(List<KeyValuePair<string, SymbolScore>> ranked)
        {
            int traded = 0;
            foreach (var entry in ranked)
            {
                if (traded >= AutoTradeTopN)
                    break;

                string symbolName = entry.Key;
                var score = entry.Value;
                var ind = _indicators[symbolName];

                if (score.Signal == "NEUTRAL")
                    continue;

                if (Positions.Any(p => p.SymbolName == symbolName && p.Label == "GQScanner"))
                    continue;

                TradeType tradeType = score.Signal == "BULLISH" ? TradeType.Buy : TradeType.Sell;
                double volume = ind.Symbol.NormalizeVolumeInUnits(LotSize);
                double atrValue = ind.ATR.Result.Last(1);
                double slPips = (atrValue * SL_ATR) / ind.Symbol.PipSize;
                double tpPips = slPips * TP_Ratio;

                var request = new MarketOrderRequest(tradeType, volume)
                {
                    SymbolName = symbolName,
                    StopLossPips = slPips,
                    TakeProfitPips = tpPips,
                    Label = "GQScanner",
                    Comment = $"Score:{score.TotalScore:+0;-0}"
                };

                var result = ExecuteMarketOrder(request);
                if (result.IsSuccessful)
                {
                    traded++;
                    Print($"Auto-traded {symbolName} {tradeType} (Score: {score.TotalScore})");
                }
                else
                {
                    Print($"Auto-trade failed for {symbolName}: {result.Error}");
                }
            }
        }
    }
}
