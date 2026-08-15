//@version=6
//+------------------------------------------------------------------+
//|                                           GQ_Order_Flow_CVD.pb   |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
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

// pivothigh/pivotlow solo devuelven valor en la barra de confirmacion (na en el resto).
// Rastrear el pivote previo con var para comparar dos pivotes consecutivos.
var float prevCvdLow = na
var float prevPriceLow = na
var float prevCvdHigh = na
var float prevPriceHigh = na

bool bullCvdDiv = false
bool bearCvdDiv = false

if not na(cvdLow) and not na(priceLow)
    if not na(prevCvdLow) and not na(prevPriceLow)
        bullCvdDiv := showDivergences and cvdLow > prevCvdLow and priceLow < prevPriceLow
    prevCvdLow := cvdLow
    prevPriceLow := priceLow

if not na(cvdHigh) and not na(priceHigh)
    if not na(prevCvdHigh) and not na(prevPriceHigh)
        bearCvdDiv := showDivergences and cvdHigh < prevCvdHigh and priceHigh > prevPriceHigh
    prevCvdHigh := cvdHigh
    prevPriceHigh := priceHigh

plotshape(bullCvdDiv, "Bull CVD Div", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(bearCvdDiv, "Bear CVD Div", shape.triangledown, location.abovebar, color.red, size=size.small)

alertcondition(bullCvdDiv, "GQ CVD Bullish Divergence", "CVD Bullish Divergence on {{ticker}}")
alertcondition(bearCvdDiv, "GQ CVD Bearish Divergence", "CVD Bearish Divergence on {{ticker}}")
