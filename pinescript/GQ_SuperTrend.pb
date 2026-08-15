//@version=6
//+------------------------------------------------------------------+
//|                                              GQ_SuperTrend.pb    |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ SuperTrend", shorttitle="GQ_ST", overlay=true)

atrPeriod = input.int(10, "ATR Period", minval=1)
multiplier = input.float(3.0, "Multiplier", minval=0.1, step=0.1)
upColor = input.color(color.rgb(0, 200, 0), "Bull Color")
downColor = input.color(color.rgb(255, 0, 0), "Bear Color")
showSignals = input.bool(true, "Show Flip Signals")

[superTrend, direction] = ta.supertrend(multiplier, atrPeriod)

// direction: -1 is uptrend (bullish), 1 is downtrend (bearish)
isBull = direction < 0
isBear = direction > 0

plot(isBull ? superTrend : na, "SuperTrend Up", upColor, 2, plot.style_linebr)
plot(isBear ? superTrend : na, "SuperTrend Down", downColor, 2, plot.style_linebr)

longCondition = ta.crossunder(direction, 0)
shortCondition = ta.crossover(direction, 0)

plotshape(showSignals and longCondition, "Buy Signal", shape.triangleup, location.belowbar, upColor, size=size.small)
plotshape(showSignals and shortCondition, "Sell Signal", shape.triangledown, location.abovebar, downColor, size=size.small)

alertcondition(longCondition, "GQ SuperTrend Buy", "SuperTrend flipped LONG on {{ticker}}")
alertcondition(shortCondition, "GQ SuperTrend Sell", "SuperTrend flipped SHORT on {{ticker}}")
