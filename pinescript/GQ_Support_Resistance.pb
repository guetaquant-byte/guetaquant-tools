//@version=6
//+------------------------------------------------------------------+
//|                                     GQ_Support_Resistance.pb     |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ Support Resistance", shorttitle="GQ_SR", overlay=true, max_lines_count=100, max_labels_count=100)

pivotLookback = input.int(10, "Pivot Lookback", minval=2)
clusterATR = input.float(1.5, "Clustering Distance (ATR multiple)", minval=0.1, step=0.1)
maxLevels = input.int(6, "Maximum Levels to Show", minval=1, maxval=20)
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
    float clusterDist = nz(atrVal, 1.0) * clusterATR
    bool merged = false
    if array.size(levelPrices) > 0
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

if barstate.islast
    for l in drawnLines
        line.delete(l)
    for lb in drawnLabels
        label.delete(lb)
    array.clear(drawnLines)
    array.clear(drawnLabels)

    if array.size(levelPrices) > 0
        for i = 0 to array.size(levelPrices) - 1
            float price = array.get(levelPrices, i)
            int touches = array.get(levelTouches, i)
            string ltype = array.get(levelTypes, i)
            bool isResistance = ltype == "R"
            color baseColor = isResistance ? color.rgb(200, 50, 50) : color.rgb(50, 200, 50)
            int lineWidth = math.min(touches, 3)
            int lineAlpha = math.min(touches * 15, 60)
            color lineColor = color.new(baseColor, lineAlpha)
            line ln = line.new(bar_index - pivotLookback * 2, price, bar_index + 10, price, color=lineColor, width=lineWidth, extend=extend.right, style=line.style_solid)
            array.push(drawnLines, ln)
            if showStrength
                label lbl = label.new(bar_index + 2, price, str.tostring(touches) + "x " + ltype, color=lineColor, style=label.style_label_center, textcolor=color.white, size=size.small)
                array.push(drawnLabels, lbl)
