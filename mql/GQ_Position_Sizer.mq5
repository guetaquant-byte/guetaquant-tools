//+------------------------------------------------------------------+
//|                                           GQ_Position_Sizer.mq5  |
//|                                                      Gueta Quant |
//|                                             https://guetaquant.com|
//|                                                                  |
//|  Aviso de Riesgo: Fines netamente educativos. Decreto 2555/2010. |
//+------------------------------------------------------------------+
#property copyright "Gueta Quant"
#property link      "https://guetaquant.com"
#property version   "1.00"
#property description "Calculador de lotaje por volatilidad ATR y control de riesgo del 2%"

//--- input parameters
input double   InpRiskPercent = 2.0;       // Riesgo Máximo por Operación (%)
input int      InpATRPeriod   = 14;        // Período de Volatilidad ATR
input double   InpATRMultiplier = 2.5;     // Multiplicador ATR para Stop Loss
input double   InpFixedStopPoints = 0.0;   // Usar Stop Fijo en Puntos (0 = Usar ATR)

//--- global variables
int            gATRHandle = INVALID_HANDLE;
double         gPoint = 0.0;
int            gDigits = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Obtener especificaciones del símbolo
   gPoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   gDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Inicializar indicador ATR si no se usa stop fijo
   if(InpFixedStopPoints <= 0.0)
   {
      gATRHandle = iATR(_Symbol, _Period, InpATRPeriod);
      if(gATRHandle == INVALID_HANDLE)
      {
         Print("Error al crear el indicador iATR. Código: ", GetLastError());
         return(INIT_FAILED);
      }
   }
   
   Print("GQ Position Sizer EA inicializado correctamente.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(gATRHandle != INVALID_HANDLE)
   {
      IndicatorRelease(gATRHandle);
   }
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
      double atrBuffer[];
      ArraySetAsSeries(atrBuffer, true);
      
      if(CopyBuffer(gATRHandle, 0, 0, 1, atrBuffer) < 1)
      {
         Print("Error al copiar datos del buffer de ATR.");
         return;
      }
      
      double atrVal = atrBuffer[0];
      stopDistance = atrVal * InpATRMultiplier;
   }
   
   // Validar distancia mínima
   if(stopDistance <= 0.0)
   {
      Comment("GQ Sizer: Esperando datos de mercado o ATR = 0...");
      return;
   }
   
   // 2. Obtener especificaciones del balance y cuenta
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * (InpRiskPercent / 100.0);
   
   // 3. Obtener valor monetario de un punto
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   
   if(tickSize <= 0.0 || tickValue <= 0.0)
   {
      Comment("GQ Sizer: Error al obtener parámetros de ticks.");
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
   
   // 5. Ajustar a los límites de volumen permitidos por el broker
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if (lotStep <= 0.0) lotStep = 0.01;   // guardia division por cero
   
   // Redondear al paso de lote permitido
   calculatedLots = MathFloor(calculatedLots / lotStep) * lotStep;
   
   // Limitar dentro de los rangos mínimo y máximo
   if(calculatedLots < minLot) calculatedLots = minLot;
   if(calculatedLots > maxLot) calculatedLots = maxLot;
   
   // 6. Mostrar panel informativo en pantalla
   string msg = "=========================================\n" +
                "    GUETA QUANT - POSITION SIZER\n" +
                "=========================================\n" +
                "Instrumento: " + _Symbol + "\n" +
                "Capital de Cuenta: " + DoubleToString(balance, 2) + " USD\n" +
                "Riesgo Máximo (" + DoubleToString(InpRiskPercent, 1) + "%): " + DoubleToString(riskMoney, 2) + " USD\n" +
                "Distancia Stop: " + DoubleToString(stopDistance, gDigits) + " (Equiv: " + DoubleToString(stopDistance / gPoint, 1) + " pips/puntos)\n" +
                "-----------------------------------------\n" +
                "LOTAJE RECOMENDADO: " + DoubleToString(calculatedLots, 2) + " Lotes\n" +
                "=========================================\n" +
                "Aviso: Fines educativos. Cuenta Demo de práctica.";
                
   Comment(msg);
}
//+------------------------------------------------------------------+
