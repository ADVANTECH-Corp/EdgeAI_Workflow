@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

call "%~dp0\chat.bat" "%NPU_MODEL_NAME%" "%CHAT_PROMPT%"
exit /b %errorlevel%
