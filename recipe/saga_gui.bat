@echo off

for %%a in (%~dp0\..) do set LIBRARY_PREFIX=%%~fa

:: Override with osgeo-forge env
if exist "%~dp0\osgeo-env.bat" call "%~dp0\osgeo-env.bat"

set "SAGA_MLB=%LIBRARY_PREFIX%\apps\saga-gis-lts;%LIBRARY_PREFIX%\bin;%LIBRARY_PREFIX%\lib\vc_x64_dll"
set "PATH=%LIBRARY_PREFIX%\lib\vc_x64_dll;%PATH%"
start /B "SAGA GIS GUI" "%LIBRARY_PREFIX%\apps\saga-gis-lts\saga_gui.exe" %*
