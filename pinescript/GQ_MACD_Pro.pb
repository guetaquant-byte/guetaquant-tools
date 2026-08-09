//@version=6
indicator(title="GQ MACD Pro", shorttitle="GQ_MACD", overlay=false)

fastLen = input.int(12, "Fast Length")
slowLen = input.int(26, "Slow Length")
signalLen = input.int(9, "Signal Length")
macdSrc = input.source(close, "Source")
showCrossLabels = input.bool(true, "Show Crossover Labels")
showDivergence = input.bool(true, "Show Divergence")

[macdLine, signalLine, histLine] = ta.macd(macdSrc, fastLen, slowLen, signalLen)

plot(macdLine, "MACD", color.blue, 2)
plot(signalLine, "Signal", color.orange, 2)

histColor = histLine >= 0 ? histLine > histLine[1] ? color.rgb(0, 200, 0) : color.rgb(0, 100, 0) : histLine > histLine[1] ? color.rgb(200, 0, 0) : color.rgb(100, 0, 0)
plot(histLine, "Histogram", histColor, 2, plot.style_histogram)

hline(0, "Zero Line", color.gray, hline.style_dotted)

crossUp = ta.crossover(macdLine, signalLine)
crossDown = ta.crossunder(macdLine, signalLine)

plotshape(showCrossLabels and crossUp, "Cross Up", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showCrossLabels and crossDown, "Cross Down", shape.triangledown, location.abovebar, color.red, size=size.small)

zeroCrossUp = ta.crossover(macdLine, 0)
zeroCrossDown = ta.crossunder(macdLine, 0)

plotshape(showCrossLabels and zeroCrossUp, "Zero Cross Up", shape.labelup, location.bottom, color.rgb(0, 150, 0), size=size.tiny)
plotshape(showCrossLabels and zeroCrossDown, "Zero Cross Down", shape.labeldown, location.top, color.rgb(150, 0, 0), size=size.tiny)

macdHigh = ta.pivothigh(macdLine, 5, 5)
macdLow = ta.pivotlow(macdLine, 5, 5)
priceHigh = ta.pivothigh(macdSrc, 5, 5)
priceLow = ta.pivotlow(macdSrc, 5, 5)

// pivothigh/pivotlow devuelven na salvo en la barra de confirmacion: comparar pivotes consecutivos con var
var float prevMacdLow = na
var float prevPriceLow = na
var float prevMacdHigh = na
var float prevPriceHigh = na

bool bullDiv = false
bool bearDiv = false

if not na(macdLow) and not na(priceLow)
    if not na(prevMacdLow) and not na(prevPriceLow)
        bullDiv := showDivergence and macdLow > prevMacdLow and priceLow < prevPriceLow
    prevMacdLow := macdLow
    prevPriceLow := priceLow

if not na(macdHigh) and not na(priceHigh)
    if not na(prevMacdHigh) and not na(prevPriceHigh)
        bearDiv := showDivergence and macdHigh < prevMacdHigh and priceHigh > prevPriceHigh
    prevMacdHigh := macdHigh
    prevPriceHigh := priceHigh

plotshape(bullDiv, "Bull Div", shape.triangleup, location.bottom, color.green, size=size.small)
plotshape(bearDiv, "Bear Div", shape.triangledown, location.top, color.red, size=size.small)

alertcondition(crossUp, "GQ MACD Bullish Cross", "MACD crossed above Signal on {{ticker}}")
alertcondition(crossDown, "GQ MACD Bearish Cross", "MACD crossed below Signal on {{ticker}}")
alertcondition(bullDiv, "GQ MACD Bullish Divergence", "MACD Bullish Divergence on {{ticker}}")
alertcondition(bearDiv, "GQ MACD Bearish Divergence", "MACD Bearish Divergence on {{ticker}}")
