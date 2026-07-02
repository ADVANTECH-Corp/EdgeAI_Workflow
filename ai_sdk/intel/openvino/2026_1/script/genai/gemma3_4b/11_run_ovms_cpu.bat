@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

call "%~dp0\run_ovms.bat" CPU "%CPU_IGPU_MODEL_PATH%" "%CPU_IGPU_MODEL_NAME%" standard
exit /b %errorlevel%
