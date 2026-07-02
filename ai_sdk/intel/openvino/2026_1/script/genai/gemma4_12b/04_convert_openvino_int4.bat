@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 12B - Step 04 - Convert to OpenVINO INT4
echo ============================================================
echo  Raw model : %RAW_MODEL%
echo  Output    : %OV_MODEL%
echo.
echo  Important: conversion is not recommended on 16 GB RAM edge devices.
echo.

if not exist "%ENV_PATH%\python.exe" (
  echo [ERROR] Python environment was not found. Run 02_prepare_convert_env.bat first.
  exit /b 1
)

if not exist "%RAW_MODEL%\config.json" (
  echo [ERROR] Raw model folder is incomplete: %RAW_MODEL%
  echo         Run 03_download_raw_model.bat first.
  exit /b 1
)

pushd "%GUIDE_ROOT%"
"%ENV_PATH%\python.exe" script\convert_gemma4_12b_openvino.py ^
  --model "%RAW_MODEL%" ^
  --output "%OV_MODEL%" ^
  --precision int4
if errorlevel 1 goto :pop_error
popd

echo [OK] OpenVINO INT4 conversion finished.
exit /b 0

:pop_error
popd
echo [ERROR] OpenVINO conversion failed.
exit /b 1
