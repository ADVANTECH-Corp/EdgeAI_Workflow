@echo off
setlocal EnableExtensions

call "%~dp0\run_ovms.bat" CPU standard
exit /b %errorlevel%
