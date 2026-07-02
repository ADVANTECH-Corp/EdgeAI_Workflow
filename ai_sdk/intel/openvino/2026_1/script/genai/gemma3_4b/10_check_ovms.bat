@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

set "RUN_OVMS_EXE=%OVMS_EXE%"
if not exist "%RUN_OVMS_EXE%" if exist "%PRODUCT_OVMS_EXE%" set "RUN_OVMS_EXE=%PRODUCT_OVMS_EXE%"

echo.
echo ============================================================
echo  Gemma 3 4B - Check OVMS
echo ============================================================
echo  OVMS: %RUN_OVMS_EXE%
echo.

if not exist "%RUN_OVMS_EXE%" (
  echo [ERROR] ovms.exe was not found.
  echo         Update OVMS_EXE in 00_config.bat or install the product OVMS.
  exit /b 1
)

"%RUN_OVMS_EXE%" --version
exit /b %errorlevel%
