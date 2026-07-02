@echo off
setlocal EnableExtensions

call "%~dp0\run_ovms.bat" GPU igpu
exit /b %errorlevel%
