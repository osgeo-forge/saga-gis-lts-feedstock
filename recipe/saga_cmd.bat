@echo off

@setlocal

for %%a in (%~dp0..) do set "LIBRARY_PREFIX=%%~fa"

:: Override with osgeo-forge env
if exist "%~dp0\osgf_env.bat" call "%~dp0\osgf_env.bat"

pushd "%LIBRARY_PREFIX%\apps\saga-ltr"

  set "SAGA=%cd%"
  set "SAGA_MLB=%cd%\modules"
  set "PATH=%cd%;%SAGA_MLB%;%LIBRARY_PREFIX%\bin;%PATH%"
  saga_cmd.exe %*

popd

@endlocal
