#!/bin/bash
CURRENT_DATE_TIME=`date +"%D %T"`
echo "###############################################" >> /home/pi/sensor_distance/mainlog.log
echo "START SCRIPT | $CURRENT_DATE_TIME" >> /home/pi/sensor_distance/mainlog.log


ALTEZZA_BOILER_CM=153
ALTEZZA_MASSIMA_ACQUA_CM=143
DISTANZA_TRA_SENSORE_E_ACQUA=10
LITRI_TOTALI_ACQUA_BOILER=3000
LITRI_PER_CM_H=$((LITRI_TOTALI_ACQUA_BOILER/$ALTEZZA_MASSIMA_ACQUA_CM))
LITRI_PER_CM_H=$((LITRI_PER_CM_H+1))

echo "litri per cm di altezza: $LITRI_PER_CM_H" >> /home/pi/sensor_distance/mainlog.log

echo "READ SENSOR VALUE" >> /home/pi/sensor_distance/mainlog.log

#### INIZIO ESECUZIONE CALCOLI ####
#VA LETTO UN VALORE INTERO DAL SENSORE
curr_sensor_value=143 #Valore in cm della distanza dal coperchio
python start_sensor.py > last_run_sensor.log
tail -1 last_run_sensor.log | cut -d ' ' -f 2 | cut -d '.' -f 1 > last_distance.log
IS_DISTANCE=`wc -l last_distance.log`
IS_ERROR=`cat last_distance.log  | grep -i Errore | wc -l`


if [ "$IS_ERROR" -eq "1" ]; then
	echo "SENSORE NON FUNZIONANTE" >> /home/pi/sensor_distance/mainlog.log
	SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: Sensore non funzionante. Verificare!"
else
	curr_sensor_value=`cat last_distance.log`
	echo "Valore rilevato dal sensore: $curr_sensor_value" >> /home/pi/sensor_distance/mainlog.log

	curr_sensor_value_to_use=$((curr_sensor_value-$DISTANZA_TRA_SENSORE_E_ACQUA)) #Tolgo lo spazio tra il sensore e il pelo dell'acqua quando il boiler è pieno
	echo "Valore rilevato dal sensore togliendo lo spazio tra sensore e acqua: $curr_sensor_value_to_use" >> /home/pi/sensor_distance/mainlog.log

	curr_high_water_from_ground=$((ALTEZZA_MASSIMA_ACQUA_CM-curr_sensor_value_to_use))
	echo "Altezza dell'acqua da terra: $curr_high_water_from_ground" >> /home/pi/sensor_distance/mainlog.log

	value_litri=$((curr_high_water_from_ground*LITRI_PER_CM_H)) #Valore calcolato in litri dell'acqua rimanente

	echo "" >> /home/pi/sensor_distance/mainlog.log
	echo "[Acqua rimanente: $value_litri Litri]" >> /home/pi/sensor_distance/mainlog.log
	value_percent=$(($((value_litri*100))/LITRI_TOTALI_ACQUA_BOILER)) #Valore percentuale dell'acqua rimanente

	if [ "$value_percent" -eq "0" ] && [ $value_litri -gt "0" ]; then
	    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: E' presente meno dell'1% di acqua. Circa $value_litri litri (lettura ultrasuoni $curr_sensor_value cm).";
	elif [ "$value_percent" -lt "1" ] && [ $value_litri -lt "1" ]; then
	    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: ATTENZIONE! ACQUA TERMINATA COMPLETAMENTE!(lettura ultrasuoni $curr_sensor_value cm).";
	else
	    SMS_TEXT_DEFAULT="[BOILER $CURRENT_DATE_TIME]: $value_percent% di acqua disponibile. Circa $value_litri litri (lettura ultrasuoni $curr_sensor_value cm).";   
	fi

	echo "[Percentuale di acqua rimanente: $value_percent%]" >> /home/pi/sensor_distance/mainlog.log
	echo "" >> /home/pi/sensor_distance/mainlog.log
	#### FINE ESECUZIONE CALCOLI ####
fi
#### PREPARO TESTO SMS ####
echo "PREPARE SMS TEXT"  >> /home/pi/sensor_distance/mainlog.log

echo "TXT: $SMS_TEXT_DEFAULT"  >> /home/pi/sensor_distance/mainlog.log
#### FINE PREPARAZIONE SMS ####


#### INVIO SMS ####
echo "START SEND"  >> /home/pi/sensor_distance/mainlog.log
isSent="N";
echo "ESITO INVIO: $isSent"  >> /home/pi/sensor_distance/mainlog.log
echo "END SEND"  >> /home/pi/sensor_distance/mainlog.log
#### FINE INVIO SMS ####

echo "END SCRIPT"  >> /home/pi/sensor_distance/mainlog.log
echo "###############################################" >> /home/pi/sensor_distance/mainlog.log
