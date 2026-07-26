//@version=6
indicator(title="GQ Market Structure", shorttitle="GQ_Struct", overlay=true)

leftBars = input.int(5, "Pivot Lookback Left")
rightBars = input.int(5, "Pivot Lookback Right")
fvgThreshold = input.float(0.0, "FVG Min Threshold (points)", step=0.01)
minSwingSize = input.float(0.0, "Minimum Swing Size (points)", step=0.01)
showFVG = input.bool(true, "Show Fair Value Gaps")
showBOS = input.bool(true, "Show BOS/CHoCH")
showOB = input.bool(true, "Show Order Blocks")

swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow = ta.pivotlow(low, leftBars, rightBars)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var float prevSwingHigh = na
var float prevSwingLow = na
var string structureType = ""

swingSizeOk(price1, price2) =>
    math.abs(price1 - price2) >= minSwingSize

if not na(swingHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHighBar := bar_index
    lastSwingHigh := swingHigh

if not na(swingLow)
    prevSwingLow := lastSwingLow
    lastSwingLowBar := bar_index
    lastSwingLow := swingLow

bool bosBull = not na(lastSwingLow) and not na(prevSwingLow) and low > lastSwingLow and lastSwingLow > prevSwingLow and swingSizeOk(lastSwingLow, prevSwingLow)
bool bosBear = not na(lastSwingHigh) and not na(prevSwingHigh) and high < lastSwingHigh and lastSwingHigh < prevSwingHigh and swingSizeOk(lastSwingHigh, prevSwingHigh)

bool chochBull = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow > lastSwingLow[1] and lastSwingHigh < lastSwingHigh[1] and swingSizeOk(lastSwingLow, lastSwingLow[1])
bool chochBear = not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh < lastSwingHigh[1] and lastSwingLow > lastSwingLow[1] and swingSizeOk(lastSwingHigh, lastSwingHigh[1])

plotshape(showBOS and bosBull, "BOS Bull", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showBOS and bosBear, "BOS Bear", shape.triangledown, location.abovebar, color.red, size=size.small)
plotshape(showBOS and chochBull, "CHoCH Bull", shape.labelup, location.belowbar, color.rgb(0, 180, 0), size=size.small)
plotshape(showBOS and chochBear, "CHoCH Bear", shape.labeldown, location.abovebar, color.rgb(180, 0, 0), size=size.small)

float fvgUpper = na
float fvgLower = na

if low[1] > high[2]
    fvgUpper := low[1]
    fvgLower := high[2]
    if fvgUpper - fvgLower > fvgThreshold and showFVG
        box.new(bar_index[2], fvgUpper, bar_index, fvgLower, border_color=color.new(color.green, 0), bgcolor=color.new(color.green, 75))

if high[1] < low[2]
    fvgUpper := low[2]
    fvgLower := high[1]
    if fvgUpper - fvgLower > fvgThreshold and showFVG
        box.new(bar_index[2], fvgUpper, bar_index, fvgLower, border_color=color.new(color.red, 0), bgcolor=color.new(color.red, 75))

float obHigh = na
float obLow = na

if not na(swingHigh)
    obHigh := high
    obLow := low
    if showOB
        box.new(bar_index - rightBars - leftBars, obHigh, bar_index, obLow, border_color=color.new(color.red, 60), bgcolor=color.new(color.red, 25))

if not na(swingLow)
    obHigh := high
    obLow := low
    if showOB
        box.new(bar_index - rightBars - leftBars, obHigh, bar_index, obLow, border_color=color.new(color.green, 60), bgcolor=color.new(color.green, 25))

trendUp = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow > lastSwingLow[1] and lastSwingHigh > lastSwingHigh[1]
trendDown = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow < lastSwingLow[1] and lastSwingHigh < lastSwingHigh[1]

bgcolor(trendUp ? color.new(color.green, 90) : trendDown ? color.new(color.red, 90) : na, title="Trend BG")

alertcondition(bosBull, "GQ BOS Bull", "Bullish Break of Structure on {{ticker}}")
alertcondition(bosBear, "GQ BOS Bear", "Bearish Break of Structure on {{ticker}}")
alertcondition(chochBull, "GQ CHoCH Bull", "Bullish Change of Character on {{ticker}}")
alertcondition(chochBear, "GQ CHoCH Bear", "Bearish Change of Character on {{ticker}}")
