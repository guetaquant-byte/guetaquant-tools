//@version=6
indicator(title="GQ Order Flow CVD", shorttitle="GQ_CVD", overlay=false)

smoothPeriod = input.int(5, "Smoothing Period")
showDivergences = input.bool(true, "Show Divergences")
showMA = input.bool(true, "Show MA Line")

float delta = volume * (close - open) / (high - low)
delta := high == low ? 0.0 : delta

var float cvd = 0.0
var float sessionOpen = open

if ta.change(time("D")) != 0
    cvd := 0.0
    sessionOpen := open

cvd += delta

smoothedCVD = ta.sma(cvd, smoothPeriod)
cvdMA = ta.sma(cvd, 14)

plot(smoothedCVD, "CVD", smoothedCVD >= 0 ? color.rgb(0, 180, 0) : color.rgb(180, 0, 0), 3, plot.style_histogram)
plot(showMA ? cvdMA : na, "CVD MA", color.blue, 2)

hline(0, "Zero", color.gray, hline.style_dotted)

cvdHigh = ta.pivothigh(smoothedCVD, 5, 5)
cvdLow = ta.pivotlow(smoothedCVD, 5, 5)
priceHigh = ta.pivothigh(close, 5, 5)
priceLow = ta.pivotlow(close, 5, 5)

bullCvdDiv = showDivergences and not na(cvdLow) and cvdLow > cvdLow[1] and not na(priceLow) and priceLow < priceLow[1]
bearCvdDiv = showDivergences and not na(cvdHigh) and cvdHigh < cvdHigh[1] and not na(priceHigh) and priceHigh > priceHigh[1]

plotshape(bullCvdDiv, "Bull CVD Div", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(bearCvdDiv, "Bear CVD Div", shape.triangledown, location.abovebar, color.red, size=size.small)

alertcondition(bullCvdDiv, "GQ CVD Bullish Divergence", "CVD Bullish Divergence on {{ticker}}")
alertcondition(bearCvdDiv, "GQ CVD Bearish Divergence", "CVD Bearish Divergence on {{ticker}}")
