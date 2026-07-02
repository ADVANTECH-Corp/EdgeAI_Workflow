@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 12B - Step 05 - Check converted model files
echo ============================================================

call :check_file "config" "%OV_MODEL%\config.json"
call :check_file "language xml" "%OV_MODEL%\openvino_language_model.xml"
call :check_file "language bin" "%OV_MODEL%\openvino_language_model.bin"
call :check_file "text embeddings" "%OV_MODEL%\openvino_text_embeddings_model.xml"
call :check_file "vision embeddings" "%OV_MODEL%\openvino_vision_embeddings_model.xml"
call :check_file "tokenizer" "%OV_MODEL%\openvino_tokenizer.xml"
call :check_file "detokenizer" "%OV_MODEL%\openvino_detokenizer.xml"
call :check_file "processor config" "%OV_MODEL%\processor_config.json"

echo.
echo [INFO] Check finished.
exit /b 0

:check_file
if exist "%~2" (echo [OK]   %~1: %~2) else (echo [MISS] %~1: %~2)
exit /b 0
