@echo off

rem Toggle OVR
rem Prevents OVR from running when not needed to save resources and soothe your worries about having several hi-res camperas owned by a subsidiary of the world's largest surveillance company constantly connected to the internet and facing you.

rem Find state. Redirect error output.
rem 0 = Stopped, 1 = Running
rem Redirect output and just display error level.

sc query OVRService | findstr /i "STATE" | findstr /i "STOPPED" 1>nul
echo Error Level: %ERRORLEVEL%

rem Toggle OVR based on error level.
if %ERRORLEVEL%==0 (
	rem Enable OVR
	echo Enabling OVR...
	sc config OVRService start= auto & sc start OVRService
) else (
	rem Disable OVR
	echo Disabling OVR...
	sc stop OVRService & sc config OVRService start= disabled
)

pause
