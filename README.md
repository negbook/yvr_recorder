# yvr_recorder
a ovr writer script for FiveM.

by using command
```
record start routename routeid
record play routename routeid isAiDriving(Follow the recorded route with NPC ai driving instead.)
record stop
```

You can bind the command to a key with [Using the new console key bindings](https://cookbook.fivem.net/2020/01/06/using-the-new-console-key-bindings/)

Important notes:
```
StartPlaybackRecordedVehicleUsingAi  -- npc driving could fail when it driving on the mountain,but after that NPC will automatic try using AI to drive to the recorded position from the yvr recorded.
StartPlaybackRecordedVehicle -- force the vehicle full-following from the recorded playback 
```

Others natives relative:
```
SetPlaybackSpeed(vehicle,speed)
SetVehicleActiveDuringPlayback(vehicle, true);
if IsPlaybackGoingOnForVehicle(vehicle) then
	StopPlaybackRecordedVehicle(vehicle); -- just end
	SkipToEndAndStopPlaybackRecordedVehicle(vehicle); -- teleport to the record end position
end
```

Step example:
[Youtube](https://www.youtube.com/watch?v=gsCJl7Us-1A)
# Step 1
record start h 1
record stop 
# Step 2 
Transfer h.ovr to h.yvr with OPENIV or other tools.
# Step 3 
Put h.yvr into stream floder in your script.
# Step 4 
### with NPC ai driving :
```
record play h 1 1
```
### Playback with your PlayerPedId
```
record play h 1
```
# Step 5 
Move yvr files to your script and copy some playback lines from my client.lua .  
So you can make some stuff like [IntialD(Showcase Video)](https://www.youtube.com/watch?v=hicW1YeqAG4])  
[IntialD(Showcase Video2)](https://www.youtube.com/watch?v=YaD424ukZKw)  