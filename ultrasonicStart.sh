#!/bin/bash
CURRENT_DATE_TIME=`date +"%D %T"`
echo "###############################################"
echo "START SCRIPT | $CURRENT_DATE_TIME" 



ALTEZZA_BOILER_CM=153
ALTEZZA_MASSIMA_ACQUA_CM=143
DISTANZA_TRA_SENSORE_E_ACQUA=10
LITRI_TOTALI_ACQUA_BOILER=3000
LITRI_PER_CM_H=$((LITRI_TOTALI_ACQUA_BOILER/$ALTEZZA_MASSIMA_ACQUA_CM))
LITRI_PER_CM_H=$((LITRI_PER_CM_H+1))

echo "litri per cm di altezza: $LITRI_PER_CM_H"

echo "READ SENSOR VALUE"

#### INIZIO ESECUZIONE CALCOLI ####
#VA LETTO UN VALORE INTERO DAL SENSORE
curr_sensor_value=143 #Valore in cm della distanza dal coperchio


echo "Valore rilevato dal sensore: $curr_sensor_value"

curr_sensor_value_to_use=$((curr_sensor_value-$DISTANZA_TRA_SENSORE_E_ACQUA)) #Tolgo lo spazio tra il sensore e il pelo dell'acqua quando il boiler è pieno
echo "Valore rilevato dal sensore togliendo lo spazio tra sensore e acqua: $curr_sensor_value_to_use"

curr_high_water_from_ground=$((ALTEZZA_MASSIMA_ACQUA_CM-curr_sensor_value_to_use))
echo "Altezza dell'acqua da terra: $curr_high_water_from_ground"

value_litri=$((curr_high_water_from_ground*LITRI_PER_CM_H)) #Valore calcolato in litri dell'acqua rimanente

echo ""
echo "[Acqua rimanente: $value_litri Litri]"
value_percent=$(($((value_litri*100))/LITRI_TOTALI_ACQUA_BOILER)) #Valore percentuale dell'acqua rimanente

if [ "$value_percent" -eq "0" ] && [ $value_litri -gt "0" ]; then
    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: E' presente meno dell'1% di acqua. Circa $value_litri litri (lettura ultrasuoni $curr_sensor_value cm).";
elif [ "$value_percent" -lt "1" ] && [ $value_litri -lt "1" ]; then
    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: ATTENZIONE! ACQUA TERMINATA COMPLETAMENTE!(lettura ultrasuoni $curr_sensor_value cm).";
else
    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: $value_percent% di acqua disponibile. Circa $value_litri litri (lettura ultrasuoni $curr_sensor_value cm).";   
fi

echo "[Percentuale di acqua rimanente: $value_percent%]"
echo ""
#### FINE ESECUZIONE CALCOLI ####


#### PREPARO TESTO SMS ####
echo "PREPARE SMS TEXT" 

echo "TXT: $SMS_TEXT_DEFAULT" 
#### FINE PREPARAZIONE SMS ####


#### INVIO SMS ####
echo "START SEND" 
isSent="N";
echo "ESITO INVIO: $isSent" 
echo "END SEND" 
#### FINE INVIO SMS ####

echo "END SCRIPT" 
echo "###############################################"