@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
set PATH="C:\GnuWin32\bin";%PATH%

@echo.======================================================================
@echo.Running unit tests using lit for the Checked C compiler
@echo.======================================================================

set OLD_DIR=%CD%
cd %LLVM_OBJ_DIR%

@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64

@echo.======================================================================
@echo.Running the Checked C regression tests
@echo.======================================================================

rem @echo ninja -v check-checkedc
rem ninja -v check-checkedc
if ERRORLEVEL 1 (goto cmdfailed)

if "%TEST_SUITE%"=="CheckedC_LLVM" (
  @echo.======================================================================
  @echo.Running the LLVM/Clang regression tests
  @echo.======================================================================
  @echo ninja -v check-all
  ninja -v check-all
  if ERRORLEVEL 1 (goto cmdfailed)

) else (
  @echo.======================================================================
  @echo.Running the Clang regression tests
  @echo.======================================================================
  @echo ninja -v check-clang
  ninja -v check-clang
  if ERRORLEVEL 1 (goto cmdfailed)
)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  @echo.Unit tests failed
  cd %OLD_DIR%
  exit /b 1
