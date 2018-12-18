:: https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Windows/

set SAGA=%SRC_DIR%\saga-gis
set SAGA_MLB=%LIBRARY_BIN%;%LIBRARY_LIB%\vc_x64_dll

set pkg_app=saga-gis-lts
set app_prefix=%LIBRARY_PREFIX%\apps\%pkg_app%

:: BUILD
pushd %SAGA%\src

  :: From OSGeo4W pkg build script
  :: docs_pdf
  sed -i "/{D32A5075-9393-4541-9631-4DE087FAABAC}.*Build\.0.*/d" saga.vc10.sln
  :: imagery_opencv
  :: sed -i "/{AC303E9F-28C5-4F95-8E25-A5D59E8DB01D}.*Build\.0.*/d" saga.vc10.sln
  :: imagery_vigra
  :: sed -i "/{596A318C-D642-4397-BC7E-6B68BEAA95FC}.*Build\.0.*/d" saga.vc10.sln
  :: io_shapes_las
  sed -i "/{315A9D51-F880-4E45-A890-60FCC4AC71DA}.*Build\.0.*/d" saga.vc10.sln

  devenv.exe saga.vc10.sln /Upgrade
  devenv.exe saga.vc10.sln /UseEnv /Build "Release|x64"

popd

:: INSTALL
:: make sure the app_prefix is available
if not exist %app_prefix%\modules mkdir %app_prefix%\modules

pushd %SAGA%\bin\saga_vc_x64
  xcopy /y /r /i modules/*.dll %app_prefix%\modules
  for %%a in (
    "saga.*.txt"
    "saga_*.dll"
    "saga_*.exe"
    "saga_prj.*"
  ) do (
    xcopy /y /r /i %%a %app_prefix%
  )
popd

:: Copy over only needed wxWidgets dlls
pushd %LIBRARY_LIB%\vc_x64_dll
  for %%a in (
    "wxbase3*u_vc*_x64.dll"
    "wxbase3*u_net_vc*_x64.dll"
    "wxbase3*u_xml_vc*_x64.dll"
    "wxmsw3*u_adv_vc*_x64.dll"
    "wxmsw3*u_aui_vc*_x64.dll"
    "wxmsw3*u_core_vc*_x64.dll"
    "wxmsw3*u_html_vc*_x64.dll"
    "wxmsw3*u_propgrid_vc*_x64.dll"
  ) do (
    xcopy /y /r /i %%a %app_prefix%
  )
popd

:: Make launch scripts
echo for %%%%a in (%%~dp0\..) do set lib_dir=%%%%~fa > %LIBRARY_BIN%\saga_cmd.bat
echo set SAGA_MLB=%%lib_dir%%\apps\%pkg_app%;%%lib_dir%%\bin >> %LIBRARY_BIN%\saga_cmd.bat
echo %%lib_dir%%\%pkg_app%\saga_cmd.exe >> %LIBRARY_BIN%\saga_cmd.bat

echo for %%%%a in (%%~dp0\..) do set lib_dir=%%%%~fa > %LIBRARY_BIN%\saga_gui.bat
echo set SAGA_MLB=%%lib_dir%%\apps\%pkg_app%;%%lib_dir%%\bin >> %LIBRARY_BIN%\saga_gui.bat
echo %%lib_dir%%\%pkg_app%\saga_gui.exe >> %LIBRARY_BIN%\saga_gui.bat
