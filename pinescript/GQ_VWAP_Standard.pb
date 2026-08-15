//@version=6
//+------------------------------------------------------------------+
//|                                           GQ_VWAP_Standard.pb    |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ VWAP Standard", shorttitle="GQ_VWAP", overlay=true)

src = input.source(hlc3, "Source")
anchorPeriod = input.string("Daily", "Anchor Period", options=["Daily", "Weekly", "Monthly"])
showBand1 = input.bool(true, "Show ±1σ Band")
showBand2 = input.bool(true, "Show ±2σ Band")
showBand3 = input.bool(true, "Show ±3σ Band")

var vwapValue = 0.0
var cumVol = 0.0
var cumVolSrc = 0.0
var cumVolSq = 0.0

isAnchor = switch anchorPeriod
    "Daily"   => ta.change(time("D")) != 0
    "Weekly"  => ta.change(time("W")) != 0
    "Monthly" => ta.change(time("M")) != 0

if isAnchor
    cumVol := 0.0
    cumVolSrc := 0.0
    cumVolSq := 0.0

cumVol += volume
cumVolSrc += src * volume
cumVolSq += src * src * volume

vwapValue := cumVolSrc / cumVol

runningStd = math.sqrt(math.max(cumVolSq / cumVol - vwapValue * vwapValue, 0))

plot(vwapValue, "VWAP", color.blue, 2)

plot(showBand1 ? vwapValue + runningStd : na, "+1σ", color.new(color.blue, 80), 1)
plot(showBand1 ? vwapValue - runningStd : na, "-1σ", color.new(color.blue, 80), 1)

plot(showBand2 ? vwapValue + 2 * runningStd : na, "+2σ", color.new(color.blue, 85), 1)
plot(showBand2 ? vwapValue - 2 * runningStd : na, "-2σ", color.new(color.blue, 85), 1)

plot(showBand3 ? vwapValue + 3 * runningStd : na, "+3σ", color.new(color.blue, 90), 1)
plot(showBand3 ? vwapValue - 3 * runningStd : na, "-3σ", color.new(color.blue, 90), 1)
