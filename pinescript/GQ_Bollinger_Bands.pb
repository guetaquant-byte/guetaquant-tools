//@version=6
//+------------------------------------------------------------------+
//|                                         GQ_Bollinger_Bands.pb    |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ Bollinger Bands", shorttitle="GQ_BB", overlay=true)

bbPeriod = input.int(20, "Period", minval=1)
bbStdDev = input.float(2.0, "StdDev", minval=0.1, step=0.1)
bbSource = input.source(close, "Source")
sqzThreshold = input.float(0.05, "Squeeze Threshold", step=0.01)
showLabels = input.bool(true, "Show Labels")

[bbMiddle, bbUpper, bbLower] = ta.bb(bbSource, bbPeriod, bbStdDev)

bandwidth = (bbUpper - bbLower) / bbMiddle

isSqueeze = bandwidth < sqzThreshold
squeezeStart = isSqueeze and not isSqueeze[1]
squeezeEnd = not isSqueeze and isSqueeze[1]

bandwidthWidening = bandwidth > bandwidth[1]

bbColor = isSqueeze ? color.yellow : bandwidthWidening ? color.rgb(0, 150, 255) : color.rgb(0, 80, 180)

plot(bbMiddle, "Middle", color.blue, 2)
pUpper = plot(bbUpper, "Upper", bbColor, 1)
pLower = plot(bbLower, "Lower", bbColor, 1)
fill(pUpper, pLower, color.new(bbColor, 85), "Band Fill")

plotshape(showLabels and squeezeStart, "Squeeze Start", shape.triangleup, location.belowbar, color.yellow, size=size.small)
plotshape(showLabels and squeezeEnd, "Squeeze End", shape.triangledown, location.abovebar, color.white, size=size.small)

alertcondition(squeezeStart, "GQ BB Squeeze Start", "Bollinger Band squeeze starting on {{ticker}}")
alertcondition(squeezeEnd, "GQ BB Squeeze Break", "Bollinger Band squeeze breaking on {{ticker}}")
