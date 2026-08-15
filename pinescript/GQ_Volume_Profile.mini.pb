//@version=6
//+------------------------------------------------------------------+
//|                                    GQ_Volume_Profile.mini.pb     |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator("GQ Volume Profile", shorttitle="GQ_VP", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=20)

rows = input.int(24, "Number of Rows", minval=5, maxval=100)
lookback = input.int(100, "Lookback Bars", minval=10, maxval=500)
showPOC = input.bool(true, "Show POC")
showVA = input.bool(true, "Show Value Area")
vaPercent = input.float(70.0, "Value Area %", minval=1, maxval=100)
colorUp = input.color(color.new(color.green, 80), "Bull Volume")
colorDown = input.color(color.new(color.red, 80), "Bear Volume")

var float pocPrice = na
var float vaHigh = na
var float vaLow = na
var line pocLine = na
var line vaHighLine = na
var line vaLowLine = na
var label pocLabel = na

var box[] vpBoxes = array.new_box()
var line[] vpLines = array.new_line()
var label[] vpLabels = array.new_label()

if barstate.islast
    for b in vpBoxes
        box.delete(b)
    for l in vpLines
        line.delete(l)
    for lb in vpLabels
        label.delete(lb)
    array.clear(vpBoxes)
    array.clear(vpLines)
    array.clear(vpLabels)

    float hiPrice = ta.highest(high, lookback)
    float loPrice = ta.lowest(low, lookback)
    float step = (hiPrice - loPrice) / rows

    if step > 0
        var float[] vol = array.new<float>(rows, 0.0)
        var float[] upVol = array.new<float>(rows, 0.0)
        var float[] dnVol = array.new<float>(rows, 0.0)
        array.fill(vol, 0.0)
        array.fill(upVol, 0.0)
        array.fill(dnVol, 0.0)

        for i = 0 to lookback - 1
            float price = close[i]
            int idx = int(math.floor((price - loPrice) / step))
            idx = math.max(0, math.min(idx, rows - 1))
            float v = nz(volume[i], 0.0)
            array.set(vol, idx, array.get(vol, idx) + v)
            if close[i] >= open[i]
                array.set(upVol, idx, array.get(upVol, idx) + v)
            else
                array.set(dnVol, idx, array.get(dnVol, idx) + v)

        float maxVol = array.max(vol)
        float totalVol = array.sum(vol)

        // POC
        int pocIdx = array.indexof(vol, maxVol)
        pocPrice := loPrice + (pocIdx + 0.5) * step

        // Value Area
        float cumVol = 0.0
        float vaTarget = totalVol * vaPercent / 100.0
        int vaLowIdx = pocIdx
        int vaHighIdx = pocIdx
        cumVol := array.get(vol, pocIdx)

        while cumVol < vaTarget and (vaLowIdx > 0 or vaHighIdx < rows - 1)
            float below = vaLowIdx > 0 ? array.get(vol, vaLowIdx - 1) : -1.0
            float above = vaHighIdx < rows - 1 ? array.get(vol, vaHighIdx + 1) : -1.0
            if below >= above and below >= 0
                vaLowIdx -= 1
                cumVol := cumVol + below
            else if above >= 0
                vaHighIdx += 1
                cumVol := cumVol + above
            else
                break

        vaHigh := loPrice + (vaHighIdx + 1) * step
        vaLow := loPrice + vaLowIdx * step

        // Draw histogram
        for i = 0 to rows - 1
            float rowVol = array.get(vol, i)
            float rowMid = loPrice + (i + 0.5) * step
            int barWidth = maxVol > 0 ? int(math.round((rowVol / maxVol) * 20)) : 0

            float up = array.get(upVol, i)
            float dn = array.get(dnVol, i)
            color c = up > dn ? colorUp : colorDown
            if rowVol > 0 and barWidth > 0
                box bx = box.new(bar_index + 1, rowMid + step * 0.45, bar_index + 1 + barWidth, rowMid - step * 0.45, border_color=c, bgcolor=c)
                array.push(vpBoxes, bx)

        // Draw POC
        if showPOC and not na(pocPrice)
            pocLine := line.new(bar_index - 20, pocPrice, bar_index + 25, pocPrice, color=color.yellow, width=2, style=line.style_dashed)
            pocLabel := label.new(bar_index + 26, pocPrice, "POC", color=color.yellow, style=label.style_label_left, textcolor=color.black, size=size.small)
            array.push(vpLines, pocLine)
            array.push(vpLabels, pocLabel)

        // Draw VA lines
        if showVA and not na(vaHigh) and not na(vaLow)
            vaHighLine := line.new(bar_index - 20, vaHigh, bar_index + 25, vaHigh, color=color.blue, width=1, style=line.style_dotted)
            vaLowLine := line.new(bar_index - 20, vaLow, bar_index + 25, vaLow, color=color.blue, width=1, style=line.style_dotted)
            array.push(vpLines, vaHighLine)
            array.push(vpLines, vaLowLine)
