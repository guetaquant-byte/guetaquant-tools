//@version=6
indicator(title="GQ Bollinger Bands", shorttitle="GQ_BB", overlay=false)

bbPeriod = input.int(20, "Period")
bbStdDev = input.float(2.0, "StdDev", step=0.1)
bbSource = input.source(close, "Source")
sqzThreshold = input.float(0.05, "Squeeze Threshold", step=0.01)
showLabels = input.bool(true, "Show Labels")

[bbMiddle, bbUpper, bbLower] = ta.bb(bbSource, bbPeriod, bbStdDev)

bandwidth = (bbUpper - bbLower) / bbMiddle
percentB = (bbSource - bbLower) / (bbUpper - bbLower)

isSqueeze = bandwidth < sqzThreshold
squeezeStart = isSqueeze and not isSqueeze[1]
squeezeEnd = not isSqueeze and isSqueeze[1]

bandwidthWidening = bandwidth > bandwidth[1]

bbColor = isSqueeze ? color.yellow : bandwidthWidening ? color.rgb(0, 150, 255) : color.rgb(0, 80, 180)

plot(bbMiddle, "Middle", color.blue, 2)
plot(bbUpper, "Upper", bbColor, 1)
plot(bbLower, "Lower", bbColor, 1)
fill(plot(bbUpper), plot(bbLower), "Band Fill", color.new(bbColor, 85))

hline(0.5, "Midline", color.gray, hline.style_dotted)
plot(percentB, "%B", color.rgb(100, 100, 255), 2)
hline(1.0, "Upper", color.new(color.red, 70), hline.style_dashed)
hline(0.0, "Lower", color.new(color.green, 70), hline.style_dashed)
hline(0.8, "Overbought", color.new(color.red, 85))
hline(0.2, "Oversold", color.new(color.green, 85))

plotshape(showLabels and squeezeStart, "Squeeze Start", shape.triangleup, location.belowbar, color.yellow, size=size.small)
plotshape(showLabels and squeezeEnd, "Squeeze End", shape.triangledown, location.abovebar, color.white, size=size.small)

alertcondition(squeezeStart, "GQ BB Squeeze Start", "Bollinger Band squeeze starting on {{ticker}}")
alertcondition(squeezeEnd, "GQ BB Squeeze Break", "Bollinger Band squeeze breaking on {{ticker}}")
