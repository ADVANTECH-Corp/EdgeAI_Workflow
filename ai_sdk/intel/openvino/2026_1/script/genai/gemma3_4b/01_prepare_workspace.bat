@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 01 - Prepare workspace
echo ============================================================
echo  Workspace  : %WORKSPACE%
echo  Model root : %MODEL_ROOT%
echo.

if not exist "%WORKSPACE%" mkdir "%WORKSPACE%"
if errorlevel 1 goto :error

if not exist "%MODEL_ROOT%" mkdir "%MODEL_ROOT%"
if errorlevel 1 goto :error

if not exist "%WORKSPACE%\envs" mkdir "%WORKSPACE%\envs"
if errorlevel 1 goto :error

echo [OK] Workspace folders are ready.
exit /b 0

:error
echo [ERROR] Failed to create workspace folders.
exit /b 1
