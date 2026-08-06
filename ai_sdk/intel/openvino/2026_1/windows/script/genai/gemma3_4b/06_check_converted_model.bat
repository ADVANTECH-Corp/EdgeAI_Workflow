@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 06 - Check converted model files
echo ============================================================

call :check_file "Language model XML" "%CPU_IGPU_MODEL_PATH%\openvino_language_model.xml"
call :check_file "Language model BIN" "%CPU_IGPU_MODEL_PATH%\openvino_language_model.bin"
call :check_file "Text embeddings XML" "%CPU_IGPU_MODEL_PATH%\openvino_text_embeddings_model.xml"
call :check_file "Vision embeddings XML" "%CPU_IGPU_MODEL_PATH%\openvino_vision_embeddings_model.xml"
call :check_file "Tokenizer XML" "%CPU_IGPU_MODEL_PATH%\openvino_tokenizer.xml"
call :check_file "Detokenizer XML" "%CPU_IGPU_MODEL_PATH%\openvino_detokenizer.xml"

echo.
echo [INFO] Check finished.
exit /b 0

:check_file
if exist "%~2" (
  echo [OK]   %~1: %~2
) else (
  echo [MISS] %~1: %~2
)
exit /b 0
