//@version=6
indicator(title="GQ RSI Pro", shorttitle="GQ_RSI", overlay=false)

rsiLength = input.int(14, "RSI Length")
rsiSource = input.source(close, "Source")
obLevel = input.int(70, "Overbought Level")
osLevel = input.int(30, "Oversold Level")
showDivergences = input.bool(true, "Show Divergences")
showHistogram = input.bool(true, "Show Histogram")

rsiValue = ta.rsi(rsiSource, rsiLength)

hline(obLevel, "Overbought", color.red, hline.style_dashed)
hline(osLevel, "Oversold", color.green, hline.style_dashed)
hline(50, "Midline", color.gray, hline.style_dotted)

plot(rsiValue, "RSI", color.purple, 2)

plot(showHistogram ? rsiValue : na, "Histogram", rsiValue > 50 ? color.rgb(0, 180, 0) : color.rgb(180, 0, 0), 2, plot.style_histogram)

// Divergencia real: comparar DOS pivotes consecutivos (precio vs RSI), no extremos rolling
rsiPivHigh = ta.pivothigh(rsiValue, 5, 5)
rsiPivLow = ta.pivotlow(rsiValue, 5, 5)
pricePivHigh = ta.pivothigh(rsiSource, 5, 5)
pricePivLow = ta.pivotlow(rsiSource, 5, 5)

var float prevRsiHigh = na
var float prevPriceHigh = na
var float prevRsiLow = na
var float prevPriceLow = na

bool bearRegDiv = false
bool bullRegDiv = false
bool bearHiddenDiv = false
bool bullHiddenDiv = false

if not na(rsiPivHigh) and not na(pricePivHigh)
    if not na(prevRsiHigh) and not na(prevPriceHigh)
        bearRegDiv := rsiPivHigh < prevRsiHigh and pricePivHigh > prevPriceHigh and rsiPivHigh > obLevel
        bearHiddenDiv := rsiPivHigh > prevRsiHigh and pricePivHigh > prevPriceHigh and rsiPivHigh < obLevel
    prevRsiHigh := rsiPivHigh
    prevPriceHigh := pricePivHigh

if not na(rsiPivLow) and not na(pricePivLow)
    if not na(prevRsiLow) and not na(prevPriceLow)
        bullRegDiv := rsiPivLow > prevRsiLow and pricePivLow < prevPriceLow and rsiPivLow < osLevel
        bullHiddenDiv := rsiPivLow < prevRsiLow and pricePivLow < prevPriceLow and rsiPivLow > osLevel
    prevRsiLow := rsiPivLow
    prevPriceLow := pricePivLow

plotshape(showDivergences and bearRegDiv, "Bear Regular", shape.triangledown, location.abovebar, color.red, size=size.small)
plotshape(showDivergences and bullRegDiv, "Bull Regular", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showDivergences and bearHiddenDiv, "Bear Hidden", shape.labeldown, location.abovebar, color.orange, size=size.small)
plotshape(showDivergences and bullHiddenDiv, "Bull Hidden", shape.labelup, location.belowbar, color.blue, size=size.small)

alertcondition(bearRegDiv, "GQ Bearish Regular Divergence", "Bearish Regular Divergence on {{ticker}}")
alertcondition(bullRegDiv, "GQ Bullish Regular Divergence", "Bullish Regular Divergence on {{ticker}}")
alertcondition(bearHiddenDiv, "GQ Bearish Hidden Divergence", "Bearish Hidden Divergence on {{ticker}}")
alertcondition(bullHiddenDiv, "GQ Bullish Hidden Divergence", "Bullish Hidden Divergence on {{ticker}}")
