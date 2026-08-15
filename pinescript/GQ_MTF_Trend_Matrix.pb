//@version=6
//+------------------------------------------------------------------+
//|                                           GQ_MTF_Trend_Matrix.pb |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
indicator(title="GQ MTF Trend Matrix", shorttitle="GQ_MTF", overlay=false)

emaFast = input.int(9, "Fast EMA")
emaMid = input.int(21, "Mid EMA")
emaSlow = input.int(50, "Slow EMA")
emaVerySlow = input.int(200, "Very Slow EMA")
src = input.source(close, "Source")

checkTF1 = input.string("1m", "TF #1", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])
checkTF2 = input.string("5m", "TF #2", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])
checkTF3 = input.string("15m", "TF #3", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])
checkTF4 = input.string("1h", "TF #4", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])
checkTF5 = input.string("4h", "TF #5", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])
checkTF6 = input.string("1D", "TF #6", options=["1m", "5m", "15m", "30m", "1h", "4h", "1D", "1W"])

trendScore(tf) =>
    [emaF, emaM, emaS, emaVS] = request.security(syminfo.tickerid, tf, [ta.ema(src, emaFast), ta.ema(src, emaMid), ta.ema(src, emaSlow), ta.ema(src, emaVerySlow)], lookahead=barmerge.lookahead_off)
    int score = 0
    score += emaF > emaM ? 1 : -1
    score += emaM > emaS ? 1 : -1
    score += emaS > emaVS ? 1 : -1
    score

tf1Score = trendScore(checkTF1)
tf2Score = trendScore(checkTF2)
tf3Score = trendScore(checkTF3)
tf4Score = trendScore(checkTF4)
tf5Score = trendScore(checkTF5)
tf6Score = trendScore(checkTF6)

overallScore = tf1Score + tf2Score + tf3Score + tf4Score + tf5Score + tf6Score
maxPossible = 18
bullPercent = (overallScore + maxPossible) / (2 * maxPossible) * 100

var table matrixTable = table.new(position.top_right, 8, 9, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)

colorForScore(s) =>
    s > 0 ? color.rgb(0, 180, 0) : s < 0 ? color.rgb(180, 0, 0) : color.gray

arrowForScore(s) =>
    s > 0 ? "▲" : s < 0 ? "▼" : "—"

fillCell(tableId, col, row, txt, txtColor, bgColor) =>
    table.cell(tableId, col, row, txt, text_color=txtColor, bgcolor=bgColor, text_size=size.small)

if barstate.islast
    fillCell(matrixTable, 0, 0, "TF", color.white, color.new(color.gray, 60))
    fillCell(matrixTable, 1, 0, "Trend", color.white, color.new(color.gray, 60))
    fillCell(matrixTable, 2, 0, "Score", color.white, color.new(color.gray, 60))

    fillCell(matrixTable, 0, 1, checkTF1, color.white, color.black)
    fillCell(matrixTable, 1, 1, arrowForScore(tf1Score), colorForScore(tf1Score), color.black)
    fillCell(matrixTable, 2, 1, str.tostring(tf1Score), colorForScore(tf1Score), color.black)

    fillCell(matrixTable, 0, 2, checkTF2, color.white, color.black)
    fillCell(matrixTable, 1, 2, arrowForScore(tf2Score), colorForScore(tf2Score), color.black)
    fillCell(matrixTable, 2, 2, str.tostring(tf2Score), colorForScore(tf2Score), color.black)

    fillCell(matrixTable, 0, 3, checkTF3, color.white, color.black)
    fillCell(matrixTable, 1, 3, arrowForScore(tf3Score), colorForScore(tf3Score), color.black)
    fillCell(matrixTable, 2, 3, str.tostring(tf3Score), colorForScore(tf3Score), color.black)

    fillCell(matrixTable, 0, 4, checkTF4, color.white, color.black)
    fillCell(matrixTable, 1, 4, arrowForScore(tf4Score), colorForScore(tf4Score), color.black)
    fillCell(matrixTable, 2, 4, str.tostring(tf4Score), colorForScore(tf4Score), color.black)

    fillCell(matrixTable, 0, 5, checkTF5, color.white, color.black)
    fillCell(matrixTable, 1, 5, arrowForScore(tf5Score), colorForScore(tf5Score), color.black)
    fillCell(matrixTable, 2, 5, str.tostring(tf5Score), colorForScore(tf5Score), color.black)

    fillCell(matrixTable, 0, 6, checkTF6, color.white, color.black)
    fillCell(matrixTable, 1, 6, arrowForScore(tf6Score), colorForScore(tf6Score), color.black)
    fillCell(matrixTable, 2, 6, str.tostring(tf6Score), colorForScore(tf6Score), color.black)

    fillCell(matrixTable, 0, 7, "TOTAL", color.white, color.new(color.gray, 60))
    fillCell(matrixTable, 1, 7, str.tostring(overallScore), colorForScore(overallScore), color.new(color.gray, 60))
    fillCell(matrixTable, 2, 7, str.tostring(math.round(bullPercent, 1)) + "%", colorForScore(overallScore), color.new(color.gray, 60))
