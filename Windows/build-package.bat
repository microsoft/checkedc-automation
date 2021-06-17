@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
set PATH="C:\GnuWin32\bin";%PATH%

set OLD_DIR=%CD%
cd %LLVM_OBJ_DIR%

if "%BUILD_PACKAGE%" == "No" (goto succeeded)

@echo.======================================================================
@echo.Building an installation package for clang
@echo.======================================================================

@echo ninja -v -j%CL_CPU_COUNT% package
ninja -v -j%CL_CPU_COUNT% package
if ERRORLEVEL 1 (goto cmdfailed)

rem Put the installer executable in its own subdirectory.
move CheckedC-Clang-*.exe package
if ERRORLEVEL 1 (goto cmdfailed)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  echo.Build installation package failed.
  cd %OLD_DIR%
  exit /b 1
