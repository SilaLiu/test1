# test1
‘Seagull #REC2 V1’ LUA Script Setup
This script has been adapted from ‘Seagull v2 zoom.lua’ which was written by Ian Lewis with a little help from Peter Hall and is designed to allow the Herelink to control a Seagull camera trigger. It was adapted by Peter Arnold  for the Seagull #REC2 and includes Manual Photo, Camera on/off and Timelapse. 
#REC and #REC2 Differences
Shutter Release
#REC Ch1 has IS-T (Autofocus – Trigger)
#REC2 has Shutter Release but no focus. Ch3 Manual Focus is recommended instead for single images.
Record Video 
#REC records video when the pwm is 1800 i.e. needs a toggle action
#REC2 Video recording uses a momentary action, i.e. Video recording is started or stopped when the pwm signal moves from neutral (1500) to 1800 then back to 1500
SBUS input added
USB Power Supply added which powers the camera inflight.
How the Script works.
The script overcomes the present apparent Herelink limitation of only allowing one Herelink button to directly control one Cube servo channel. As an example, two buttons are needed to control Seagull #REC2 Ch 2 Zoom. One button to zoom in and another to zoom out. If Seagull #REC2 Ch 2 Zoom connected to servo 12 only one Herelink button could be assigned to channel 12 which means you could zoom in but not out or vis versa. The LUA script overcomes this limitation.  
Except for Zoom the Herelink buttons are set to Toggle. The toggle settings are either High (true)  when the pwm >= 1501 or Low (false) when the pwm < 1500. The script monitors the pwm of the channels and when they change from High to low or Low to High then an action is triggered. As an example, if Button D is Long Pressed then Timelapse is either started or stopped (if running).
Herelink Zoom buttons use a momentary action and the amount of zoom depends on how long the button is pressed. 
The script uses Herelink channels 11 to 16 on Bus 1 and Cube Servo channels 11 to 14 or AUX 3 to AUX 6. Note the Herelink channels are not related to the servo channels.
The script sends message to the ground station when an action triggered.
Seagull #REC2 Setup
Use the Seagull-REC2-Config Tool to set PWM or SBUS as per the manual.
SBUS
The #REC2 SBUS can be connected to the CUBE via the SBUSo pins. The rear pin is the signal pin or white wire. 
Set the Mission Planner parameter BRD_SBUS_OUT = 1. 
#REC2 SBUS Channels
Set #REC2 Ch1 to SBUS CH11
Set #REC2 Ch2 to SBUS CH12
Set #REC2 Ch3 to SBUS CH13
Set #REC2 Ch4 to SBUS CH14

PWM
Connect  #REC2 Ch1 wire to Cube AUX 3 (CH11)
Connect  #REC2 Ch2 wire to Cube AUX 4 (CH12)
Connect  #REC2 Ch3 wire to Cube AUX 5 (CH13)
Connect  #REC2 Ch4 wire to Cube AUX 6 (CH14)
USB Power Supply
To use the #REC2 to power the camera via the servo pins or SBUSo pins, the servo bus needs to be powered. (5 Volts suggested?)
Sony Cameras set ‘USB Power Supply’ to ON
A small power plug symbol will appear beside the battery icon when the camera is being powered via the #REC2
Mission Planner Parameter Settings 
Set SCR_ENABLE to 1. This enables LUA scripts
Adjusted SCR_HEAP_SIZE  to increase or decrease the amount of memory available for scripts. 150,000 works?
Set the following Values
SERVO11_FUNCTION Value to 94
SERVO12_FUNCTION Value to 95
SERVO13_FUNCTION Value to 96
SERVO14_FUNCTION Value to 97
Use MAVFtp  to  copy the  LUA script to the SD Card scripts  folder.
HereLink Button Setup 
REC, 		Cam Long Press, Toggle, Default Value 1100, Active Value 2000, Ch 11, Bus 1
Zoom Out, 	B Short Press, Momentary, Default Value 1100, Active Value 2000, Ch 12, Bus 1
Zoom In, 	C Short Press, Momentary, Default Value 1100, Active Value 2000, Ch 13, Bus 1 
Manual Photo, 	Cam Short Press, Toggle, Default Value 1100, Active Value 2000, Ch 14, Bus 1
On/Off, 	D Short Press, Toggle, Default Value 1100, Active Value 2000, Ch 15, Bus 1
Timelapse, 	D Long Press, Toggle, Default Value 1100, Active Value 2000, Ch 16, Bus 1 
On/Off Function
On some Sony camera models, the On/Off  function will not turn the camera back on. For example, soft ON models like HX series it works, but on QX it doesn't turn the camera it back ON. The RX100 works OK but not the A6300. If the camera isn’t compatible then delete the Herelink On/Off, D Short Press button setting and use normal camera on/off.


 

HereLink Channels Seagull #REC2 Summary

Device	Neutral 	Trigger	Cube Ch	Cube AUX Ch	Servo	Script	Script Code	HereLink
Button	HereLink
Acton	HereLink
M/T	Herelink Default Value	Herelink Active Value	HereLink
Channel	HereLink
Bus
Seagull Ch 1 Shutter														
Seagull Ch 1 REC	1500	1800	11	3	11	1	94	CAM	Long Press	T	1100	2000	11	1
Seagull Ch 2 Zoom Out	1500		12	4	12		95	B	Short Press	M	1100	2000	12	1
Seagull Ch 2 Zoom IN	1500		12	4	12		95	C	Short Press	M	1100	2000	13	1
Seagull Ch 3
Man Photo	1175	F 1500
S 1800	13	5	13	2	96	CAM	Short Press	T	1100	2000	14	1
Seagull Ch 4
On/Off	1500	1800	14	6	14	4	97	D	Short Press	T	1100	2000	15	1
Seagull Ch 4
TimeLapse	1500	1175	14	6	14			D	Long Press	T	1100	2000	16	1


