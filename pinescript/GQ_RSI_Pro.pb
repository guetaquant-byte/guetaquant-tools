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

rsiHigh = ta.highest(rsiValue, rsiLength)
rsiLow = ta.lowest(rsiValue, rsiLength)
priceHigh = ta.highest(rsiSource, rsiLength)
priceLow = ta.lowest(rsiSource, rsiLength)

bearRegDiv = rsiValue < rsiValue[1] and rsiValue < rsiLow[1] and rsiSource > rsiSource[1] and rsiSource > priceHigh[1] and rsiValue > obLevel
bullRegDiv = rsiValue > rsiValue[1] and rsiValue > rsiLow[1] and rsiSource < rsiSource[1] and rsiSource < priceLow[1] and rsiValue < osLevel
bearHiddenDiv = rsiValue < rsiValue[1] and rsiValue < rsiLow[1] and rsiSource > rsiSource[1] and rsiSource > priceHigh[1] and rsiValue < obLevel
bullHiddenDiv = rsiValue > rsiValue[1] and rsiValue > rsiLow[1] and rsiSource < rsiSource[1] and rsiSource < priceLow[1] and rsiValue > osLevel

plotshape(showDivergences and bearRegDiv, "Bear Regular", shape.triangledown, location.abovebar, color.red, size=size.small)
plotshape(showDivergences and bullRegDiv, "Bull Regular", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showDivergences and bearHiddenDiv, "Bear Hidden", shape.labeldown, location.abovebar, color.orange, size=size.small)
plotshape(showDivergences and bullHiddenDiv, "Bull Hidden", shape.labelup, location.belowbar, color.blue, size=size.small)

alertcondition(bearRegDiv, "GQ Bearish Regular Divergence", "Bearish Regular Divergence on {{ticker}}")
alertcondition(bullRegDiv, "GQ Bullish Regular Divergence", "Bullish Regular Divergence on {{ticker}}")
alertcondition(bearHiddenDiv, "GQ Bearish Hidden Divergence", "Bearish Hidden Divergence on {{ticker}}")
alertcondition(bullHiddenDiv, "GQ Bullish Hidden Divergence", "Bullish Hidden Divergence on {{ticker}}")
