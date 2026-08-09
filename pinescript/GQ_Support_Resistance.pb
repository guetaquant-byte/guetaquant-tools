//@version=6
indicator(title="GQ Support Resistance", shorttitle="GQ_SR", overlay=true)

pivotLookback = input.int(10, "Pivot Lookback")
clusterATR = input.float(1.5, "Clustering Distance (ATR multiple)", step=0.1)
maxLevels = input.int(6, "Maximum Levels to Show")
showStrength = input.bool(true, "Show Level Strength")

atrVal = ta.atr(14)

swingHigh = ta.pivothigh(high, pivotLookback, pivotLookback)
swingLow = ta.pivotlow(low, pivotLookback, pivotLookback)

var float[] levelPrices = array.new_float(0)
var int[] levelTouches = array.new_int(0)
var string[] levelTypes = array.new_string(0)

if not na(swingHigh) or not na(swingLow)
    float newLevel = not na(swingHigh) ? swingHigh : swingLow
    string newType = not na(swingHigh) ? "R" : "S"
    float clusterDist = atrVal * clusterATR
    bool merged = false
    for i = 0 to array.size(levelPrices) - 1
        float existing = array.get(levelPrices, i)
        if math.abs(newLevel - existing) <= clusterDist
            float weightedAvg = (existing * array.get(levelTouches, i) + newLevel) / (array.get(levelTouches, i) + 1)
            array.set(levelPrices, i, weightedAvg)
            array.set(levelTouches, i, array.get(levelTouches, i) + 1)
            merged := true
            break
    if not merged
        array.push(levelPrices, newLevel)
        array.push(levelTouches, 1)
        array.push(levelTypes, newType)

while array.size(levelPrices) > maxLevels * 2
    int minIdx = 0
    int minTouches = array.get(levelTouches, 0)
    for i = 1 to array.size(levelTouches) - 1
        if array.get(levelTouches, i) < minTouches
            minTouches := array.get(levelTouches, i)
            minIdx := i
    array.remove(levelPrices, minIdx)
    array.remove(levelTouches, minIdx)
    array.remove(levelTypes, minIdx)

var line[] drawnLines = array.new_line()
var label[] drawnLabels = array.new_label()
for i = 0 to array.size(levelPrices) - 1
    float price = array.get(levelPrices, i)
    int touches = array.get(levelTouches, i)
    string ltype = array.get(levelTypes, i)
    bool isResistance = ltype == "R"
    color lineColor = isResistance ? color.rgb(200, 50, 50) : color.rgb(50, 200, 50)
    int lineWidth = math.min(touches, 3)
    float lineAlpha = math.min(50 + touches * 15, 100)
    lineColor := color.new(lineColor, 100 - lineAlpha)
    line.new(bar_index - pivotLookback * 2, price, bar_index + 10, price, color=lineColor, width=lineWidth, extend=extend.right, style=isResistance ? line.style_solid : line.style_solid)
    if showStrength
        label.new(bar_index + 2, price, str.tostring(touches) + "x " + ltype, color=lineColor, style=label.style_label_center, textcolor=color.white, size=size.small)
