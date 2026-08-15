//@version=6
//+------------------------------------------------------------------+
//|                                         GQ_Market_Structure.pb   |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ Market Structure", shorttitle="GQ_Struct", overlay=true, max_boxes_count=500)

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

swingSizeOk(price1, price2) =>
    math.abs(price1 - price2) >= minSwingSize

if not na(swingHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHighBar := bar_index[rightBars]
    lastSwingHigh := swingHigh

if not na(swingLow)
    prevSwingLow := lastSwingLow
    lastSwingLowBar := bar_index[rightBars]
    lastSwingLow := swingLow

bool bosBull = not na(lastSwingLow) and not na(prevSwingLow) and low > lastSwingLow and lastSwingLow > prevSwingLow and swingSizeOk(lastSwingLow, prevSwingLow) and low[1] <= lastSwingLow
bool bosBear = not na(lastSwingHigh) and not na(prevSwingHigh) and high < lastSwingHigh and lastSwingHigh < prevSwingHigh and swingSizeOk(lastSwingHigh, prevSwingHigh) and high[1] >= lastSwingHigh

bool chochBull = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow > lastSwingLow[1] and lastSwingHigh < lastSwingHigh[1] and swingSizeOk(lastSwingLow, lastSwingLow[1])
bool chochBear = not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh < lastSwingHigh[1] and lastSwingLow > lastSwingLow[1] and swingSizeOk(lastSwingHigh, lastSwingHigh[1])

plotshape(showBOS and bosBull, "BOS Bull", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showBOS and bosBear, "BOS Bear", shape.triangledown, location.abovebar, color.red, size=size.small)
plotshape(showBOS and chochBull, "CHoCH Bull", shape.labelup, location.belowbar, color.rgb(0, 180, 0), size=size.small)
plotshape(showBOS and chochBear, "CHoCH Bear", shape.labeldown, location.abovebar, color.rgb(180, 0, 0), size=size.small)

// 3-Bar Fair Value Gaps (FVG)
var box lastFvgUp = na
var box lastFvgDn = na

if low > high[2]
    float fvgUpper = low
    float fvgLower = high[2]
    if (fvgUpper - fvgLower) > fvgThreshold and showFVG
        if not na(lastFvgUp)
            box.delete(lastFvgUp)
        lastFvgUp := box.new(bar_index[2], fvgUpper, bar_index, fvgLower, border_color=color.new(color.green, 0), bgcolor=color.new(color.green, 75))

if high < low[2]
    float fvgUpper = low[2]
    float fvgLower = high
    if (fvgUpper - fvgLower) > fvgThreshold and showFVG
        if not na(lastFvgDn)
            box.delete(lastFvgDn)
        lastFvgDn := box.new(bar_index[2], fvgUpper, bar_index, fvgLower, border_color=color.new(color.red, 0), bgcolor=color.new(color.red, 75))

// Order Blocks
var box lastObHigh = na
var box lastObLow = na

if not na(swingHigh) and showOB
    float obHigh = high[rightBars]
    float obLow = low[rightBars]
    if not na(lastObHigh)
        box.delete(lastObHigh)
    lastObHigh := box.new(bar_index - rightBars, obHigh, bar_index, obLow, border_color=color.new(color.red, 60), bgcolor=color.new(color.red, 75))

if not na(swingLow) and showOB
    float obHigh = high[rightBars]
    float obLow = low[rightBars]
    if not na(lastObLow)
        box.delete(lastObLow)
    lastObLow := box.new(bar_index - rightBars, obHigh, bar_index, obLow, border_color=color.new(color.green, 60), bgcolor=color.new(color.green, 75))

trendUp = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow > lastSwingLow[1] and lastSwingHigh > lastSwingHigh[1]
trendDown = not na(lastSwingLow) and not na(lastSwingHigh) and lastSwingLow < lastSwingLow[1] and lastSwingHigh < lastSwingHigh[1]

bgcolor(trendUp ? color.new(color.green, 90) : trendDown ? color.new(color.red, 90) : na, title="Trend BG")

alertcondition(bosBull, "GQ BOS Bull", "Bullish Break of Structure on {{ticker}}")
alertcondition(bosBear, "GQ BOS Bear", "Bearish Break of Structure on {{ticker}}")
alertcondition(chochBull, "GQ CHoCH Bull", "Bullish Change of Character on {{ticker}}")
alertcondition(chochBear, "GQ CHoCH Bear", "Bearish Change of Character on {{ticker}}")
