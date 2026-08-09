//+------------------------------------------------------------------+
//|                                           GQ_Position_Sizer.mq4  |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
#property copyright "Gueta Quant"
#property link      "https://guetaquant.com"
#property version   "1.00"
#property description "Calculador de lotaje por volatilidad ATR y control de riesgo del 2% (MT4)"
#property strict

//--- input parameters
input double   InpRiskPercent = 2.0;       // Riesgo Máximo por Operación (%)
input int      InpATRPeriod   = 14;        // Período de Volatilidad ATR
input double   InpATRMultiplier = 2.5;     // Multiplicador ATR para Stop Loss
input double   InpFixedStopPoints = 0.0;   // Usar Stop Fijo en Puntos (0 = Usar ATR)

//--- global variables
double         gPoint = 0.0;
int            gDigits = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Obtener especificaciones del símbolo en MT4
   gPoint = MarketInfo(Symbol(), MODE_POINT);
   gDigits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   
   Print("GQ Position Sizer EA (MT4) inicializado correctamente.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // No indicators handles require release on MT4 legacy API
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double stopDistance = 0.0;
   
   // 1. Determinar distancia de Stop Loss
   if(InpFixedStopPoints > 0.0)
   {
      stopDistance = InpFixedStopPoints * gPoint;
   }
   else
   {
      // En MQL4 usamos la llamada directa del buffer iATR
      double atrVal = iATR(Symbol(), Period(), InpATRPeriod, 0);
      stopDistance = atrVal * InpATRMultiplier;
   }
   
   // Validar distancia mínima
   if(stopDistance <= 0.0)
   {
      Comment("GQ Sizer (MT4): Esperando datos de mercado o ATR = 0...");
      return;
   }
   
   // 2. Obtener especificaciones del balance y cuenta
   double balance = AccountBalance();
   double riskMoney = balance * (InpRiskPercent / 100.0);
   
   // 3. Obtener valor monetario de un punto (En MT4 se extraen vía MarketInfo)
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   
   if(tickSize <= 0.0 || tickValue <= 0.0)
   {
      Comment("GQ Sizer (MT4): Error al obtener parámetros de ticks.");
      return;
   }
   
   // Convertir distancia de stop a ticks
   double stopTicks = stopDistance / tickSize;
   
   // 4. Calcular tamaño de posición (Lotes)
   // Lotes = Riesgo en USD / (Distancia de Stop en Ticks * Valor de un Tick)
   double calculatedLots = 0.0;
   if(stopTicks > 0.0)
   {
      calculatedLots = riskMoney / (stopTicks * tickValue);
   }
   
   // 5. Ajustar a los límites de volumen permitidos por el broker en MT4
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (lotStep <= 0.0) lotStep = 0.01;   // guardia division por cero
   
   // Redondear al paso de lote permitido
   calculatedLots = MathFloor(calculatedLots / lotStep) * lotStep;
   
   // Limitar dentro de los rangos mínimo y máximo
   if(calculatedLots < minLot) calculatedLots = minLot;
   if(calculatedLots > maxLot) calculatedLots = maxLot;
   
   // 6. Mostrar panel informativo en pantalla
   string msg = "=========================================\n" +
                "   GUETA QUANT - POSITION SIZER (MT4)\n" +
                "=========================================\n" +
                "Instrumento: " + Symbol() + "\n" +
                "Capital de Cuenta: " + DoubleToString(balance, 2) + " USD\n" +
                "Riesgo Máximo (" + DoubleToString(InpRiskPercent, 1) + "%): " + DoubleToString(riskMoney, 2) + " USD\n" +
                "Distancia Stop: " + DoubleToString(stopDistance, gDigits) + " (Equiv: " + DoubleToString(stopDistance / gPoint, 1) + " pips/puntos)\n" +
                "-----------------------------------------\n" +
                "LOTAJE RECOMENDADO: " + DoubleToString(calculatedLots, 2) + " Lotes\n" +
                "=========================================\n" +
                "Aviso: Fines educativos. Cuenta Demo de práctica.";
                
   Comment(msg);
}
