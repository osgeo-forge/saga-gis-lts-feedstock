@echo off

for %%a in (%~dp0\..) do set LIBRARY_PREFIX=%%~fa

:: Override with osgeo-forge env
if exist "%~dp0\osgf_env.bat" call "%~dp0\osgf_env.bat"

set "SAGA_MLB=%LIBRARY_PREFIX%\apps\saga-ltr;%LIBRARY_PREFIX%\bin"
set "PATH=%LIBRARY_PREFIX%\bin;%PATH%"
"%LIBRARY_PREFIX%\apps\saga-ltr\saga_cmd.exe" %*
