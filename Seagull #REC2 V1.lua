-- Ch 1 2 3 4 Ver 03 Final Beta.lua
--[[ 
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


--]]


-- Video Manual Photo Setup Start 
-- Video
local VideoTrigger = false -- Same as ShutterTrigger below just for the long press action. 
local laststateVideo = false -- Same as last state but for channel 11. 
local video = 1 -- video recording state, when set to 1 the shutter action will trigger when pressed, when 2 shutter action is blocked to prevent stopping recording video with accidental shutter input.
local SERVO_FUNCTION_VIDEO = 94 -- 94 is the Script 1 servo output in Ardupilot.  Video

-- Manual Photo
local ShutterTrigger = false -- ShutterTrigger is used in the short press action to check  the Current state for short press input and is set by the script on loop.
local laststateShutter  = false -- Last state is used log the last position of channel 14 input and is set by the script on loop.
local SERVO_FUNCTION_SHUTTER = 96 -- 96 is the Script 2 servo output in Ardupilot. Shutter 
local chanShut = SRV_Channels:find_channel(SERVO_FUNCTION_SHUTTER) -- sets chanShut to output servo action 
pwmaVideo = rc:get_pwm(11) -- gets pwm value from ch11 and assigns it to the lable pwmaVideo.

-- The next two if statements sets the default positions of the inputs and sets them to match on boot based on the current input positions. 
if pwmaVideo <= 1500 then 
    VideoTrigger = false
    laststateVideo = VideoTrigger
    video = 1

elseif pwmaVideo >= 1501 then
    VideoTrigger = true
    laststateVideo = VideoTrigger
    video = 1 
end
-- Video manual Photo Setup Finish 

-- On Off TimeLapse Setup Start 

local OnOff_Trigger = false -- OnOff_Trigger is used in the short press action to check  the Current state for short press input and is set by the script on loop.
local laststateOnOff  = false -- Last state is used log the last position of channel 14 input and is set by the script on loop.
local TimelapseTrigger = false -- Same as OnOff_Trigger just for the long press action. 
local laststateTimelapse = false -- Same as last state but for channel 16. 
local Timelapse = 1 -- Timelapse recording state, when set to 1 the shutter action will trigger when pressed, when 2 shutter action is blocked to prevent stopping recording Timelapse with accidental shutter input.
local SERVO_FUNCTION_OnOff_Timelapse = 97 -- 97 is the Script 4 servo output in Ardupilot. On/Off Timelapse



local chanOnOffTimelapse = SRV_Channels:find_channel(SERVO_FUNCTION_OnOff_Timelapse) -- sets chanOnOffTimelapse to output servo action 

pwmTimelapse = rc:get_pwm(16) -- gets pwm value from ch16 and assigns it to the lable pwmTimelapse.

-- These next two if statements sets the default positions of the inputs and sets them to match on boot based on the current input positions. 
if pwmTimelapse <= 1500 then 
    TimelapseTrigger = false
    laststateTimelapse = TimelapseTrigger
    Timelapse = 1

elseif pwmTimelapse >= 1501 then
    TimelapseTrigger = true
    laststateTimelapse = TimelapseTrigger
    Timelapse = 1 
end

-- On Off TimeLapse Setup Finish 



-- Video manual Photo functions Start 

function shutter_focus()
    SRV_Channels:set_output_pwm_chan_timeout(chanShut, 1500, 1000) -- This sets the time for the camera Focus trigger 1000ms.
     --gcs:send_text(0, "Shutter Focus")
    return shutter_fire, 1100
  end

  function shutter_fire()
    SRV_Channels:set_output_pwm_chan_timeout(chanShut, 1800, 200) -- This sets the time for the camera shutter trigger 2500ms.
    gcs:send_text(0, "Shutter Focus & Trigger")
    laststateShutter  = ShutterTrigger
    return update, 300
  end
  
 
-- Video manual Photo functions Finish 
 
-- Zoom Setup Start 
 
 local SERVO_FUNCTION_ZOOM = 95 -- 95 is the Script 2 servo output in Ardupilot. 
 

-- Zoom Setup Finish 
 
 
 gcs:send_text(0, "Seagull camera trigger Script for Herelink running") -- This sends a message to the ground station to say the script is running.
  
 
 --************** Main Function Loop Start ********************
 
function update()  -- This is the loop section of the script.

  -- On Off TimeLapse Loop Start 
  
  pwmOnOff = rc:get_pwm(15) -- gets pwm of ch 15, if less than or equal to 1500 then it sets OnOff_Trigger to false
    if pwmOnOff <= 1500 then 
        OnOff_Trigger = false
        
    elseif pwmOnOff >= 1501 then -- gets pwm of ch 14, if more than or equal to 1501 then it sets OnOff_Trigger to true
        OnOff_Trigger = true
    end 

    pwmTimelapse = rc:get_pwm(16) -- gets pwm of ch 16, if less than or equal to 1500 then it sets TimelapseTrigger to false
    
    if pwmTimelapse <= 1500 then 
            TimelapseTrigger = false
            
        elseif pwmTimelapse >= 1501 then -- gets pwm of ch 16, if more than or equal to 1501 then it sets TimelapseTrigger to true
            TimelapseTrigger = true
    end 

    if (Timelapse == 1) then -- This is the check for Timelapse recording has ended and also sets the output back to 1500 pwm mid point. 
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_OnOff_Timelapse, 1500)
    end
    
    if not (OnOff_Trigger == laststateOnOff ) and (Timelapse == 1) and (video == 1) then -- This sets the output to 1800 momentary to turn on/off  if the state on ch 16 changes to turn off
        SRV_Channels:set_output_pwm_chan_timeout(chanOnOffTimelapse, 1800, 500) -- This sets the time for the camera OnOff trigger. 
        gcs:send_text(0, "On-Off Trigger")
        laststateOnOff  = OnOff_Trigger


        elseif not (TimelapseTrigger == laststateTimelapse) and (Timelapse == 1) and (video == 1) then -- This sets the output to 1800 if the state on ch 16 changes ie has an input to trigger timelapse.
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_OnOff_Timelapse, 1175) -- Timelaspe usesa toggle seting i.e. when pwm = 1175 then timelaspe will run
        gcs:send_text(0, "Timelapse Start")
        laststateOnOff  = OnOff_Trigger
        laststateTimelapse = TimelapseTrigger
        Timelapse = 2 -- This sets the Timelapse tag to 2 and prevents the short single press to tun off. 


        elseif not (TimelapseTrigger == laststateTimelapse) and (Timelapse == 2) then -- This takes the input from ch 16 and stops Timelapse recording. 
         SRV_Channels:set_output_pwm(SERVO_FUNCTION_OnOff_Timelapse, 1500)
        gcs:send_text(0, "Timelapse Stop")
        laststateOnOff  = OnOff_Trigger
        laststateTimelapse = TimelapseTrigger
        Timelapse = 1         
      
    end   
    
   -- On Off TimeLapseLoop Stuff Finish 
    
   -- Video manual Photo Loop  Start 
   
    pwmaVideo = rc:get_pwm(11) -- gets pwm of Herelink ch 11, if less than or equal to 1500 then it sets VideoTrigger to false
    
    if pwmaVideo <= 1500 then 
            VideoTrigger = false
            
        elseif pwmaVideo >= 1501 then -- gets pwm of Herelink ch 11, if more than or equal to 1501 then it sets VideoTrigger to true
            VideoTrigger = true
    end 

    pwmVShutter = rc:get_pwm(14) -- gets pwm of ch 14, if less than or equal to 1500 then it sets ShutterTrigger to false
       
    if pwmVShutter <= 1500 then 
        ShutterTrigger = false
            
    elseif pwmVShutter >= 1501 then -- gets pwm of ch 14, if more than or equal to 1501 then it sets ShutterTrigger to true
        ShutterTrigger = true
    end 

    SRV_Channels:set_output_pwm(SERVO_FUNCTION_SHUTTER, 1175) -- Set Cube Neutral for Manaul Focus
    SRV_Channels:set_output_pwm(SERVO_FUNCTION_VIDEO, 1500) -- Set Cube Video channel back to neutral


    if not(ShutterTrigger == laststateShutter ) and (video == 1)  then -- If the state on ch 14 changes ie has an input to trigger the shutter the shutter focus and trigger functions are called
        return shutter_focus, 500 -- waits the amount set in the time before calling function 
   
    elseif not (VideoTrigger == laststateVideo) and (video == 1) and Timelapse == 1 then -- This sets the output to 1800 if the state on ch 11 changes ie has an input to trigger recording.
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_VIDEO, 1800) -- Momentary trigger and reset back to neutral earlier in loop
        gcs:send_text(0, "Video Record")
        laststateVideo = VideoTrigger
        video = 2 -- This sets the video tag to 2 and prevents the short single press stopping video recording. 

    elseif not (VideoTrigger == laststateVideo) and (video == 2) then -- This takes the input from ch 11 and stops video recording. 
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_VIDEO, 1800)
        gcs:send_text(0, "Video Stop")
        laststateShutter  = ShutterTrigger
        laststateVideo = VideoTrigger
        video = 1 
        
    end 
 -- Video manual Photo Loop Finish  
 
-- Zoom  Start 
 
  pwmZoomOut = rc:get_pwm(12) -- gets pwm of ch 12 - Zoom Out
  pwmZoomIn = rc:get_pwm(13) -- gets pwm of ch 13 - Zoom In
  

    if pwmZoomIn >= 1501 then 
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_ZOOM, 1700)

    elseif pwmZoomOut >= 1501 then -- 
            SRV_Channels:set_output_pwm(SERVO_FUNCTION_ZOOM, 1300)
        else
        SRV_Channels:set_output_pwm(SERVO_FUNCTION_ZOOM, 1500) -- this stops zoooming if herelink button is released      
    end
 
-- Zoom  Finish 

  return update, 500 -- This loops the script every 500ms. 

end
 --******************** Main Function Loop Finish ********************
 
return update(), 3000 -- This sets a delay to start the script on boot. 