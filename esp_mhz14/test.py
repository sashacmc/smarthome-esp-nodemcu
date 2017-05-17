#!/usr/bin/python

import serial
import time 

port = "/dev/ttyUSB0"
usart = serial.Serial(port, 9600)
cmd = [0xFF,0x01,0x86,0x00,0x00,0x00,0x00,0x00,0x79]

while 1:
	usart.write(cmd)
	res = usart.read(9)
	if ord(res[0]) == 0xFF and ord(res[1]) == 0x86:
		hl = ord(res[2])
		ll = ord(res[3])

		ppm = hl * 256 + ll
		print "PPM:", ppm
	else:
		print "Wrong answer", ord(res[0]), ord(res[1])
	
	time.sleep(1)	

