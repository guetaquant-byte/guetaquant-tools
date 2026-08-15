//@version=6
//+------------------------------------------------------------------+
//|                                           GQ_Anchored_VWAP.pb    |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ Anchored VWAP", shorttitle="GQ_AVWAP", overlay=true)

anchorMethod = input.string("Timestamp", "Anchor Method", options=["Timestamp", "Bar Index", "Swing Point"])
anchorTimestamp = input.time(timestamp("01 Jan 2022"), "Anchor Timestamp (for Timestamp method)")
anchorBar = input.int(0, "Anchor Bar Index (for Bar Index method)")
showBand1 = input.bool(true, "Show ±1σ Band")
showBand2 = input.bool(true, "Show ±2σ Band")

src1 = input.source(hlc3, "VWAP #1 Source")
showVWAP1 = input.bool(true, "Show VWAP #1")
anchor1Active = input.bool(true, "VWAP #1 Active")

src2 = input.source(hlc3, "VWAP #2 Source")
showVWAP2 = input.bool(false, "Show VWAP #2")
anchor2Timestamp = input.time(timestamp("01 Jun 2022"), "VWAP #2 Timestamp")

src3 = input.source(hlc3, "VWAP #3 Source")
showVWAP3 = input.bool(false, "Show VWAP #3")
anchor3Timestamp = input.time(timestamp("01 Jan 2023"), "VWAP #3 Timestamp")

isAnchor1 = false
isAnchor2 = false
isAnchor3 = false

if anchorMethod == "Timestamp"
    isAnchor1 := time >= anchorTimestamp
    isAnchor2 := time >= anchor2Timestamp
    isAnchor3 := time >= anchor3Timestamp
else if anchorMethod == "Bar Index"
    isAnchor1 := bar_index == anchorBar
else
    swingLowPivot = ta.pivotlow(low, 5, 5)
    swingHighPivot = ta.pivothigh(high, 5, 5)
    isAnchor1 := not na(swingLowPivot) or not na(swingHighPivot)

var float cumVol1 = 0.0
var float cumVolSrc1 = 0.0
var float cumVolSq1 = 0.0
var bool anchored1 = false

if anchor1Active
    if not anchored1 and isAnchor1
        anchored1 := true
        cumVol1 := 0.0
        cumVolSrc1 := 0.0
        cumVolSq1 := 0.0
    if anchored1
        cumVol1 += volume
        cumVolSrc1 += src1 * volume
        cumVolSq1 += src1 * src1 * volume

vwap1 = anchored1 and cumVol1 > 0 ? cumVolSrc1 / cumVol1 : na
std1 = anchored1 and cumVol1 > 0 ? math.sqrt(math.max(cumVolSq1 / cumVol1 - vwap1 * vwap1, 0)) : na

var float cumVol2 = 0.0
var float cumVolSrc2 = 0.0
var float cumVolSq2 = 0.0
var bool anchored2 = false

if not anchored2 and isAnchor2
    anchored2 := true
    cumVol2 := 0.0
    cumVolSrc2 := 0.0
    cumVolSq2 := 0.0
if anchored2
    cumVol2 += volume
    cumVolSrc2 += src2 * volume
    cumVolSq2 += src2 * src2 * volume

vwap2 = anchored2 and cumVol2 > 0 ? cumVolSrc2 / cumVol2 : na
std2 = anchored2 and cumVol2 > 0 ? math.sqrt(math.max(cumVolSq2 / cumVol2 - vwap2 * vwap2, 0)) : na

var float cumVol3 = 0.0
var float cumVolSrc3 = 0.0
var float cumVolSq3 = 0.0
var bool anchored3 = false

if not anchored3 and isAnchor3
    anchored3 := true
    cumVol3 := 0.0
    cumVolSrc3 := 0.0
    cumVolSq3 := 0.0
if anchored3
    cumVol3 += volume
    cumVolSrc3 += src3 * volume
    cumVolSq3 += src3 * src3 * volume

vwap3 = anchored3 and cumVol3 > 0 ? cumVolSrc3 / cumVol3 : na
std3 = anchored3 and cumVol3 > 0 ? math.sqrt(math.max(cumVolSq3 / cumVol3 - vwap3 * vwap3, 0)) : na

plot(showVWAP1 and anchor1Active ? vwap1 : na, "AVWAP #1", color.blue, 2)
plot(showVWAP1 and anchor1Active and showBand1 and not na(std1) ? vwap1 + std1 : na, "AVWAP #1 +1σ", color.new(color.blue, 80), 1)
plot(showVWAP1 and anchor1Active and showBand1 and not na(std1) ? vwap1 - std1 : na, "AVWAP #1 -1σ", color.new(color.blue, 80), 1)
plot(showVWAP1 and anchor1Active and showBand2 and not na(std1) ? vwap1 + 2 * std1 : na, "AVWAP #1 +2σ", color.new(color.blue, 85), 1)
plot(showVWAP1 and anchor1Active and showBand2 and not na(std1) ? vwap1 - 2 * std1 : na, "AVWAP #1 -2σ", color.new(color.blue, 85), 1)

plot(showVWAP2 ? vwap2 : na, "AVWAP #2", color.orange, 2)
plot(showVWAP2 and showBand1 and not na(std2) ? vwap2 + std2 : na, "AVWAP #2 +1σ", color.new(color.orange, 80), 1)
plot(showVWAP2 and showBand1 and not na(std2) ? vwap2 - std2 : na, "AVWAP #2 -1σ", color.new(color.orange, 80), 1)
plot(showVWAP2 and showBand2 and not na(std2) ? vwap2 + 2 * std2 : na, "AVWAP #2 +2σ", color.new(color.orange, 85), 1)
plot(showVWAP2 and showBand2 and not na(std2) ? vwap2 - 2 * std2 : na, "AVWAP #2 -2σ", color.new(color.orange, 85), 1)

plot(showVWAP3 ? vwap3 : na, "AVWAP #3", color.purple, 2)
plot(showVWAP3 and showBand1 and not na(std3) ? vwap3 + std3 : na, "AVWAP #3 +1σ", color.new(color.purple, 80), 1)
plot(showVWAP3 and showBand1 and not na(std3) ? vwap3 - std3 : na, "AVWAP #3 -1σ", color.new(color.purple, 80), 1)
plot(showVWAP3 and showBand2 and not na(std3) ? vwap3 + 2 * std3 : na, "AVWAP #3 +2σ", color.new(color.purple, 85), 1)
plot(showVWAP3 and showBand2 and not na(std3) ? vwap3 - 2 * std3 : na, "AVWAP #3 -2σ", color.new(color.purple, 85), 1)
