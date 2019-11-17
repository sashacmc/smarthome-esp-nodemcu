# прошивка моих плат
esptool.py --port /dev/ttyUSB0 write_flash -fm qio -fs 32m 0x00000 nodemcu-master-13-modules-2016-08-25-11-00-14-float.bin 0x3fc000 esp_init_data_default.bin

# прошивка sonoff
esptool.py --port /dev/ttyUSB5 write_flash -fm dout -fs 1MB 0x00000 nodemcu-master-13-modules-2016-08-25-11-00-14-float.bin 0xfc000 esp_init_data_default.bin

# набор модулей при сборке прошивки
bit dht enduser_setup file gpio i2c net node struct tmr tsl2561 uart wifi

