//@version=6
indicator(title="GQ SuperTrend", shorttitle="GQ_ST", overlay=true)

atrPeriod = input.int(10, "ATR Period")
multiplier = input.float(3.0, "Multiplier", step=0.1)
src = input.source(hl2, "Source")
upColor = input.color(color.rgb(0, 200, 0), "Bull Color")
downColor = input.color(color.rgb(255, 0, 0), "Bear Color")
showSignals = input.bool(true, "Show Flip Signals")

atrValue = ta.atr(atrPeriod)

upperBand = src + multiplier * atrValue
lowerBand = src - multiplier * atrValue

var int trend = 1
var float superTrend = 0.0
var float prevSuperTrend = 0.0

prevSuperTrend := superTrend[1]

if na(prevSuperTrend)
    superTrend := src
    trend := 1
else
    if trend[1] == 1
        if src > prevSuperTrend
            superTrend := math.max(upperBand, prevSuperTrend)
        else
            superTrend := lowerBand
            trend := -1
    else
        if src < prevSuperTrend
            superTrend := math.min(lowerBand, prevSuperTrend)
        else
            superTrend := upperBand
            trend := 1

plot(trend == 1 ? superTrend : na, "SuperTrend Up", upColor, 2)
plot(trend == -1 ? superTrend : na, "SuperTrend Down", downColor, 2)

plotshape(showSignals and ta.cross(trend, 1) and trend == 1, "Buy Signal", shape.triangleup, location.belowbar, upColor, size=size.small)
plotshape(showSignals and ta.cross(trend, -1) and trend == -1, "Sell Signal", shape.triangledown, location.abovebar, downColor, size=size.small)

longCondition = trend == 1 and trend[1] == -1
shortCondition = trend == -1 and trend[1] == 1

alertcondition(longCondition, "GQ SuperTrend Buy", "SuperTrend flipped LONG on {{ticker}}")
alertcondition(shortCondition, "GQ SuperTrend Sell", "SuperTrend flipped SHORT on {{ticker}}")
