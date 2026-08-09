//@version=6
indicator("GQ Volume Profile", overlay=true, max_lines_count=500)

rows = input.int(24, "Number of Rows")
lookback = input.int(100, "Lookback Bars")
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
    // Limpiar dibujos de recomputos anteriores (evita acumulacion hasta max_boxes_count)
    for b in vpBoxes
        box.delete(b)
    for l in vpLines
        line.delete(l)
    for lb in vpLabels
        label.delete(lb)
    array.clear(vpBoxes)
    array.clear(vpLines)
    array.clear(vpLabels)

    float high = ta.highest(high, lookback)
    float low = ta.lowest(low, lookback)
    float step = (high - low) / rows
    if step <= 0
        runtime.error("Price range too narrow")
    
    var float[] vol = array.new<float>(rows, 0.0)
    var float[] upVol = array.new<float>(rows, 0.0)
    var float[] dnVol = array.new<float>(rows, 0.0)
    array.fill(vol, 0.0)
    array.fill(upVol, 0.0)
    array.fill(dnVol, 0.0)
    
    for i = 0 to lookback - 1
        float price = close[i]
        int idx = int(math.floor((price - low) / step))
        idx = math.min(idx, rows - 1)
        float v = volume[i]
        array.set(vol, idx, array.get(vol, idx) + v)
        if close[i] >= open[i]
            array.set(upVol, idx, array.get(upVol, idx) + v)
        else
            array.set(dnVol, idx, array.get(dnVol, idx) + v)
    
    float maxVol = array.max(vol)
    float totalVol = array.sum(vol)
    
    // POC
    int pocIdx = array.indexof(vol, maxVol)
    pocPrice := low + (pocIdx + 0.5) * step
    
    // Value Area
    float cumVol = 0.0
    float vaTarget = totalVol * vaPercent / 100.0
    int vaLowIdx = pocIdx
    int vaHighIdx = pocIdx
    cumVol := array.get(vol, pocIdx)
    
    while cumVol < vaTarget and (vaLowIdx > 0 or vaHighIdx < rows - 1)
        float below = vaLowIdx > 0 ? array.get(vol, vaLowIdx - 1) : -1
        float above = vaHighIdx < rows - 1 ? array.get(vol, vaHighIdx + 1) : -1
        if below >= above and below >= 0
            vaLowIdx -= 1
            cumVol := cumVol + below
        else if above >= 0
            vaHighIdx += 1
            cumVol := cumVol + above
        else
            break
    
    vaHigh := low + (vaHighIdx + 1) * step
    vaLow := low + vaLowIdx * step
    
    // Draw histogram
    for i = 0 to rows - 1
        float rowVol = array.get(vol, i)
        float rowMid = low + (i + 0.5) * step
        float barWidth = (rowVol / maxVol) * step * 3
        
        float up = array.get(upVol, i)
        float dn = array.get(dnVol, i)
        color c = up > dn ? colorUp : colorDown
        if rowVol > 0
            array.push(vpBoxes, box.new(bar_index + 1, rowMid - step / 2, bar_index + 1 + barWidth, rowMid + step / 2,
             border_color=c, bgcolor=c, text="", text_color=na))
    
    // Draw POC
    if showPOC
        pocLine := line.new(bar_index - 20, pocPrice, bar_index + 20, pocPrice,
         color=color.yellow, width=2, style=line.style_dashed)
        pocLabel := label.new(bar_index + 5, pocPrice, "POC",
         color=color.yellow, style=label.style_label_up, textcolor=color.black, size=size.small)
    
    // Draw VA lines
    if showVA
        vaHighLine := line.new(bar_index - 20, vaHigh, bar_index + 20, vaHigh,
         color=color.blue, width=1, style=line.style_dotted)
        vaLowLine := line.new(bar_index - 20, vaLow, bar_index + 20, vaLow,
         color=color.blue, width=1, style=line.style_dotted)
