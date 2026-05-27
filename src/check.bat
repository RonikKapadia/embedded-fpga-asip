@REM @set FILES=pixel_pusher.vhd
@set FILES=%1

@ghdl -s %FILES%
@if %ERRORLEVEL%==1 exit /b 1

@echo All Good!