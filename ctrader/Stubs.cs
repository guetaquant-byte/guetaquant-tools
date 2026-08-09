// Stub de la API de cTrader Automate para el gate de sintaxis en CI (dotnet build).
// La compilación ALGO real solo ocurre dentro de cTrader Automate (SDK propietario).
// Este archivo permite validar sintaxis/tipos de nuestros cBots sin el SDK.
// NO incluir en releases ni afirmar que es la API oficial.

using System;
using System.Collections.Generic;
using System.Linq;

namespace cAlgo.API
{
    public enum TradeType { Buy, Sell }
    public enum TimeFrame { Minute1, Minute5, Minute15, Hour1, Hour4, Day, Week }

    public class Series
    {
        public double Last(int index) => 0;
        public double this[int i] => 0;
        public int Count => 0;
        public double Maximum(int count) => 0;
        public double Minimum(int count) => 0;
    }

    public class Symbol
    {
        public double Bid { get; set; }
        public double Ask { get; set; }
        public double PipSize { get; set; }
        public double TickSize { get; set; }
        public double TickValue { get; set; }
        public double LotSize { get; set; }
        public double VolumeInUnitsMin { get; set; }
        public double VolumeInUnitsMax { get; set; }
        public double VolumeInUnitsStep { get; set; }
        public string Name { get; set; }
        public double NormalizeVolumeInUnits(double v) => v;
        public double NormalizeVolume(double v) => v;
    }

    public class Bars
    {
        public Series ClosePrices { get; set; } = new Series();
        public Series HighPrices { get; set; } = new Series();
        public Series LowPrices { get; set; } = new Series();
        public Series OpenPrices { get; set; } = new Series();
        public Series TickVolume { get; set; } = new Series();
        public int Count => 0;
        public double Last(int index) => 0;
    }

    public class Position
    {
        public long Id { get; set; }
        public string Label { get; set; }
        public string SymbolName { get; set; }
        public TradeType TradeType { get; set; }
        public double EntryPrice { get; set; }
        public double VolumeInUnits { get; set; }
        public double NetProfit { get; set; }
        public double GrossProfit { get; set; }
        public double? StopLoss { get; set; }
        public double? TakeProfit { get; set; }
    }

    public class PendingOrder
    {
        public long Id { get; set; }
        public string Label { get; set; }
        public string SymbolName { get; set; }
        public TradeType TradeType { get; set; }
        public double EntryPrice { get; set; }
    }

    public class TradeResult
    {
        public bool IsSuccessful { get; set; }
        public object Error { get; set; }
    }

    public class Robot : IDisposable
    {
        public Symbol Symbol { get; set; }
        public Bars Bars { get; set; }
        public IEnumerable<Position> Positions => Array.Empty<Position>();
        public IEnumerable<PendingOrder> PendingOrders => Array.Empty<PendingOrder>();
        public MarketData MarketData { get; set; }
        public IndicatorsApi Indicators { get; set; }
        public Account Account { get; set; }

        protected void Print(string msg) { }
        protected TradeResult ClosePosition(Position pos) => new TradeResult { IsSuccessful = true };
        protected TradeResult ClosePosition(Position pos, double volume) => new TradeResult { IsSuccessful = true };
        protected TradeResult CancelPendingOrder(PendingOrder order) => new TradeResult { IsSuccessful = true };
        protected TradeResult ModifyPosition(Position pos, double? sl, double? tp) => new TradeResult { IsSuccessful = true };
        protected TradeResult PlaceStopOrder(TradeType t, double volume, double price, string label, double? sl, double? tp) => new TradeResult { IsSuccessful = true };
        protected TradeResult PlaceLimitOrder(TradeType t, double volume, double price, string label, double? sl, double? tp) => new TradeResult { IsSuccessful = true };
        protected TradeResult PlaceMarketOrder(TradeType t, double volume, string label, double? sl, double? tp) => new TradeResult { IsSuccessful = true };

        protected virtual void OnStart() { }
        protected virtual void OnTick() { }
        protected virtual void OnBar() { }
        protected virtual void OnBarClosed() { }
        protected virtual void OnStop() { }
        protected virtual void OnPositionOpened(Position pos) { }
        protected virtual void OnPositionClosed(Position pos) { }
        protected virtual void OnPositionModified(Position pos) { }
        protected virtual void OnPendingOrderOpened(PendingOrder order) { }
        protected virtual void OnPendingOrderClosed(PendingOrder order) { }

        public virtual void Dispose() { }
    }

    public class Account
    {
        public double Equity { get; set; }
        public double Balance { get; set; }
        public string Currency { get; set; }
    }

    public class MarketData
    {
        public Series GetSeries(string symbol, TimeFrame tf) => new Series();
        public Bars GetBars(string symbol, TimeFrame tf) => new Bars();
        public Series GetTicks(string symbol) => new Series();
    }

    public class IndicatorsApi
    {
        public AverageTrueRange AverageTrueRange(int period, MovingAverageType maType = MovingAverageType.Simple) => new AverageTrueRange();
        public ExponentialMovingAverage ExponentialMovingAverage(Series src, int period) => new ExponentialMovingAverage();
        public SimpleMovingAverage SimpleMovingAverage(Series src, int period) => new SimpleMovingAverage();
        public RelativeStrengthIndex RelativeStrengthIndex(Series src, int period) => new RelativeStrengthIndex();
        public Momentum Momentum(Series src, int period) => new Momentum();
        public BollingerBands BollingerBands(Series src, int period, double dev, MovingAverageType maType = MovingAverageType.Simple) => new BollingerBands();
        public MacdHistogram MacdHistogram(Series src, int fast, int slow, int signal) => new MacdHistogram();
        public TrueRange TrueRange(Series src) => new TrueRange();
        public ParabolicSAR ParabolicSAR(double step, double max) => new ParabolicSAR();
        public Supertrend Supertrend(int period, int multiplier) => new Supertrend();
        public Supertrend SuperTrend(int period, int multiplier, Series h, Series l, Series c) => new Supertrend();
    }

    public enum MovingAverageType { Simple, Exponential, Weighted, Smoothed }

    public class AverageTrueRange
    {
        public Series Result { get; set; } = new Series();
    }
    public class ExponentialMovingAverage
    {
        public Series Result { get; set; } = new Series();
    }
    public class SimpleMovingAverage
    {
        public Series Result { get; set; } = new Series();
    }
    public class RelativeStrengthIndex
    {
        public Series Result { get; set; } = new Series();
    }
    public class Momentum
    {
        public Series Result { get; set; } = new Series();
    }
    public class Supertrend
    {
        public Series UpTrend { get; set; } = new Series();
        public Series DownTrend { get; set; } = new Series();
        public Series Result { get; set; } = new Series();
    }
    public class SuperTrend : Supertrend { }   // alias de tipo usado por GQ_Trend_Follower
    public class BollingerBands
    {
        public Series Result { get; set; } = new Series();
        public Series Upper { get; set; } = new Series();
        public Series Lower { get; set; } = new Series();
        public Series Middle { get; set; } = new Series();
    }
    public class MacdHistogram
    {
        public Series Result { get; set; } = new Series();
        public Series Histogram { get; set; } = new Series();
        public Series Signal { get; set; } = new Series();
    }
    public class TrueRange
    {
        public Series Result { get; set; } = new Series();
    }
    public class ParabolicSAR
    {
        public Series Result { get; set; } = new Series();
    }
    public class TextBlock
    {
        public Thickness Padding { get; set; }
        public string Text { get; set; }
    }

    public struct Thickness
    {
        public Thickness(double uniform) { }
        public Thickness(double left, double top, double right, double bottom) { }
    }

    public enum TimeZones { UTC }
    public enum AccessRights { None, FileSystem }
    public enum Color { Red, Lime, Green, Blue, Gold, Orange, White, Black, RoyalBlue, DodgerBlue }

    public class ParameterAttribute : Attribute
    {
        public ParameterAttribute(string name = "") { }
        public string Group { get; set; }
        public object DefaultValue { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }
        public double Step { get; set; }
    }

    public class RobotAttribute : Attribute
    {
        public TimeZones TimeZone { get; set; }
        public AccessRights AccessRights { get; set; }
    }

    public class IndicatorAttribute : Attribute
    {
        public string Name { get; set; }
        public string Group { get; set; }
    }
}

namespace cAlgo.API.Indicators
{
    using cAlgo.API;
    public class RelativeStrengthIndex2 : Indicator { }   // reservado
    public class Indicator { public Series Result { get; set; } = new Series(); }
}

namespace cAlgo.API.Requests
{
    using cAlgo.API;
    public class StopOrderRequest
    {
        public TradeType TradeType { get; set; }
        public double Volume { get; set; }
        public double Price { get; set; }
        public string Label { get; set; }
        public double? StopLoss { get; set; }
        public double? TakeProfit { get; set; }
        public TimeSpan? ExpirationTime { get; set; }
    }
}

namespace cAlgo.API.Internals
{
    using cAlgo.API;
    public class Broker : IDisposable
    {
        public virtual void Dispose() { }
    }
}
