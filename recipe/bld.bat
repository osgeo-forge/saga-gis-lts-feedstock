:: https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Windows/

:: set "LIBRARY_PREFIX_SLASH=%LIBRARY_PREFIX:\=/%"

set GDAL=%LIBRARY_PREFIX%
:: set HARU=%LIBRARY_PREFIX%
:: set LIBLAS=%LIBRARY_PREFIX%
set OPENCV=%LIBRARY_PREFIX%
set PGSQL=%LIBRARY_PREFIX%
set PROJ4=%LIBRARY_PREFIX%
:: set VIGRA=%LIBRARY_PREFIX%
set WXWIN=%LIBRARY_PREFIX%
set WXWINLIB=%WXWIN%\lib\vc_x64_dll

set SAGA=%SRC_DIR%\saga-gis
set SAGA_LIB=%SAGA%\bin\saga_vc_x64
set SAGA_MLB=%LIBRARY_BIN%;%WXWINLIB%

set app_prefix=%LIBRARY_PREFIX%\apps\%PKG_NAME%


:: BUILD
:: use VS2015 devenv
set "PATH=%PF86%\Microsoft Visual Studio 14.0\Common7\IDE:%PATH%"

pushd %SAGA%\src

  :: From OSGeo4W pkg build script
  :: skip docs_pdf
  sed -i "/{D32A5075-9393-4541-9631-4DE087FAABAC}.*Build\.0.*/d" saga.vc10.sln
  if %errorlevel% neq 0 exit /b %errorlevel%

  :: skip imagery_opencv
  sed -i "/{AC303E9F-28C5-4F95-8E25-A5D59E8DB01D}.*Build\.0.*/d" saga.vc10.sln
  if %errorlevel% neq 0 exit /b %errorlevel%

  :: skip imagery_vigra
  sed -i "/{596A318C-D642-4397-BC7E-6B68BEAA95FC}.*Build\.0.*/d" saga.vc10.sln
  if %errorlevel% neq 0 exit /b %errorlevel%

  :: skip io_shapes_las (requires really old v1.6.0)
  sed -i "/{315A9D51-F880-4E45-A890-60FCC4AC71DA}.*Build\.0.*/d" saga.vc10.sln
  if %errorlevel% neq 0 exit /b %errorlevel%

  :: From SAGA appveyor.yml
  :: skip proj
  :: sed -i '/{05EC4432-92F8-4400-87EA-11542DA70D07}.*Build\.0.*/d' saga.vc10.sln
  :: if %errorlevel% neq 0 exit /b %errorlevel%

  :: make sure we can find conda pkg installs:
  set "INCLUDE=%LIBRARY_INC%;%INCLUDE%"
  set "LIB=%WXWINLIB%;%LIBRARY_LIB%;%LIB%"

  :: This fails, probably due to inconsistent patching with line endings
  ::   (upgrade patched instead)
  :: devenv saga.vc10.sln /upgrade
  :: if %errorlevel% neq 0 exit /b %errorlevel%

  :: Allow failure, if it happens
  devenv saga.vc10.sln /clean "Release|x64"

  :: Build 'saga_api' first, or it fails to be found in a parallel build
  devenv saga.vc10.sln /project "saga_api" /build "Release|x64"
  if %errorlevel% neq 0 exit /b %errorlevel%
  devenv saga.vc10.sln /build "Release|x64"
  if %errorlevel% neq 0 exit /b %errorlevel%

  :: Alt build
  :: msbuild saga.vc10.sln /nologo /maxcpucount /p:configuration=release /p:platform=x64 /target:build
  :: if %errorlevel% neq 0 exit /b %errorlevel%

popd

:: INSTALL
:: make sure the app_prefix is available
if not exist %app_prefix% mkdir %app_prefix%

pushd %SAGA%\bin\saga_vc_x64
  xcopy /y /s /i modules %app_prefix%\modules
  if %errorlevel% neq 0 exit /b %errorlevel%
  for %%G in (
    "saga.*.txt"
    "saga_*.dll"
    "saga_*.exe"
    "saga_prj.*"
  ) do (
    xcopy /y /r /i %%G %app_prefix%
    if %errorlevel% neq 0 exit /b %errorlevel%
  )
popd

:: Copy over only needed wxWidgets dlls; otherwise,
::   QGIS Processing provider needs hacked to also find wx DLLs
pushd %LIBRARY_LIB%\vc_x64_dll
  for %%G in (
    "wxbase3*u_vc*_x64.dll"
    "wxbase3*u_net_vc*_x64.dll"
    "wxbase3*u_xml_vc*_x64.dll"
    "wxmsw3*u_adv_vc*_x64.dll"
    "wxmsw3*u_aui_vc*_x64.dll"
    "wxmsw3*u_core_vc*_x64.dll"
    "wxmsw3*u_html_vc*_x64.dll"
    "wxmsw3*u_propgrid_vc*_x64.dll"
  ) do (
    xcopy /y /r /i %%G %app_prefix%
  )
popd

:: Install launch scripts
copy "%RECIPE_DIR%\saga_cmd.bat" "%LIBRARY_BIN%\saga_cmd.bat"
if %errorlevel% neq 0 exit /b %errorlevel%
copy "%RECIPE_DIR%\saga_gui.bat" "%LIBRARY_BIN%\saga_gui.bat"
if %errorlevel% neq 0 exit /b %errorlevel%
