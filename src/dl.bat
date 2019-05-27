@echo OFF
rem Expand variables at execution time instead of at parse time.
rem This prevents issues with directories ending up in the wrong place.
setlocal enableDelayedExpansion
rem Enable command extensions for automatic recursive mkdir.
setlocal enableextensions

rem CONFIG
rem Directories
set cacheDir=%APPDATA%\Xanadu\dl\
set library=%HOMEPATH%\Music\Library\
rem END CONFIG

rem STATE
set artist=""
set type=""
rem END STATE

rem GLOBAL INIT
rem Get cache.
set cache=%cacheDir%\cache.db
rem END GLOBAL INIT

rem MAIN
call :init "%*"
rem Exit if initialization failed.
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
call :get_input
call :set_environment
call :run_helper %type%
call :download "%*"
call :clean_up
exit /B 0
rem END MAIN


rem Subroutines
rem PROGRAM
:download
echo Downloading to %cd%
echo.
rem Run youtube-dl with supplied options.
youtube-dl "%*"
exit /B %ERRORLEVEL%


:get_input
call :artist
call :type
goto :eof


:clean_up
call :save_cache
goto :eof


:init
rem Exit if no arguments were provided.
if [%1]==[] goto no_args

rem Create cache.
if not exist "%cacheDir%" (
	mkdir "%cacheDir%"
	
	@echo LAST_ARTIST_NAME=Various Artists> "%cache%"
)

rem Load cache into corresponding environment variables.
for /f "delims== tokens=1,2" %%G in ( %cache% ) do set %%G=%%H

rem Navigate to library
cd "%library%"
echo Downloading video...
echo Location: %cd%
echo.
exit /B %ERRORLEVEL%


:run_helper
rem Create appropriate folder under 'Videos', then run youtube-dl with any specified parameters.
if "%1"=="1" call :h_documentary
if "%1"=="2" call :h_interview
if "%1"=="3" call :h_live
if "%1"=="4" call :h_music_video
if "%1"=="5" call :h_session
if "%1"=="6" call :h_misc
goto :eof


:set_environment
rem Navigate to or create the artist directory.
if exist "%artist%\" (
	cd "%artist%"
) else (
	mkdir "%artist%"
	cd "%artist%"
)

rem Navigate to or create the Videos directory.
if exist Videos\ (
	cd Videos
) else (
	mkdir Videos
	cd Videos
)
goto :eof
rem END PROGRAM


rem INPUT
:artist
rem Ask for the artist name.
set /P artist=Artist name (%LAST_ARTIST_NAME%):

rem Use last artist name if no artist name is provided.
if "%artist%"=="""" (
  rem Ask for artist name again if no last artist name is available.
  if "%LAST_ARTIST_NAME%"=="""" (
    goto artist
  ) else (
    set artist=%LAST_ARTIST_NAME%
  )
)
goto :eof


:type
rem Ask the user which type of video we are downloading.
echo.
echo Available types:
echo.
echo 1. Documentary
echo 2. Interview
echo 3. Live
echo 4. Music Video
echo 5. Session
echo 6. Miscellaneous
echo.

set /P type=Select a video type: 
echo.

rem Make sure type isn't empty, and is within range.
rem God help you if you don't use a nice, safe integer.
if "%type%"=="" call :type
rem TODO: Fix range checking.
rem if "%type%" LSS 1 call :type
rem if "%type%" GTR 6 call :type
rem TODO: Implement integer casting.
goto :eof
rem END INPUT


rem DOWNLOAD ROUTINES
:h_documentary
if exist "Documentaries\" (
	cd Documentaries
) else (
	mkdir Documentaries
	cd Documentaries
)
goto :eof


:h_interview
if exist "Interviews\" (
	cd Interviews
) else (
	mkdir Interviews
	cd Interviews
)
goto :eof


:h_live
if exist "Live\" (
	cd Live
) else (
	mkdir Live
	cd Live
)
goto :eof


:h_misc
if exist "Miscellaneous\" (
	cd Miscellaneous
) else (
	mkdir Miscellaneous
	cd Miscellaneous
)
goto :eof


:h_music_video
if exist "Music Videos\" (
	cd "Music Videos"
) else (
	mkdir "Music Videos"
	cd "Music Videos"
)
goto :eof


:h_session
if exist "Sessions\" (
	cd Sessions
) else (
	mkdir Sessions
	cd Sessions
)
goto :eof
rem END DOWNLOAD ROUTINES


rem MISC ROUTINES
:save_cache
rem Save cache.
@echo LAST_ARTIST_NAME=%ARTIST%> "%cacheDir%\cache.db"
goto :eof


:no_args
echo No arguments provided. Please provide a URL and optional arguments
exit /B 1
rem END MISC ROUTINES
