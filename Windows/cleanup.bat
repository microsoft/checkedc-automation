@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
set PATH="C:\GnuWin32\bin";%PATH%

@echo.======================================================================
@echo.Cleaning Checked C src and build dirs
@echo.======================================================================

if "%CLEAN_SRC_BUILD_DIR%"=="No" (
  @echo.Clean.Src.Build.Dir is set to No. Nothing to clean.

) else if "%CLEAN_SRC_BUILD_DIR%"=="Yes" (
  @echo.Clean.Src.Build.Dir is set to Yes. Trying to clean dirs.

  if exist %BUILD_SOURCESDIRECTORY% (
    @echo.Cleaning src dir: %BUILD_SOURCESDIRECTORY%
    rmdir /s /q %BUILD_SOURCESDIRECTORY%
    if ERRORLEVEL 1 (goto cmdfailed)
  ) else (
    @echo.Src dir %BUILD_SOURCESDIRECTORY% not found
  )

  if exist %LLVM_OBJ_DIR% (
    @echo.Cleaning build dir: %LLVM_OBJ_DIR%
    rmdir /s /q %LLVM_OBJ_DIR%
    if ERRORLEVEL 1 (goto cmdfailed)
  ) else (
    @echo.Build dir %LLVM_OBJ_DIR% not found
  )
)

:cmdfailed
  @echo.Cleanup failed
  exit /b 1
