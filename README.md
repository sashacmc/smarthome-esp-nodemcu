# smarthome-esp-nodemcu
Lua (nodemcu) code for smarthome-esp boards

## esp_mhz14
Firmware for esp07_co2
* Measures temperature and pressure by BMP280
* Measures CO2 level by MH-Z14
* Sends data to thingspeak.com
* Returns current status over HTTP

## esp_mon
Firmware for esp07_1w board
* Monitors several ds18b20 sensors
* Sends data to thingspeak.com

### esp_mon/web
Simple web application to display information from thingspeak.com

### esp_mon/nagios
Nagios scripts for thingspeak.com data from esp07_1w board.

## esp_mhz14
Firmware for esp07_co2
* Measures temperature and pressure by BMP280
* Measures CO2 level by MH-Z14
* Sends data to thingspeak.com
* Returns current status over HTTP

## esp_smarthome
Firmware for esp07_4PIO_6S_v2 and esp07_ups boards
* Controls outputs
* Reads inputs
* Measures temperature, humidity and illuminate level
* Returns current status over HTTP
* Sends notifies over HTTP
* Sends data to thingspeak.com
* Separate scenarios and configs for different boards
* On-air updates.
 	
