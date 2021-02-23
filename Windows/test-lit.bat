@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
rem set PATH="C:\GnuWin32\bin";%PATH%

@echo.======================================================================
@echo.Running unit tests using lit for the Checked C compiler
@echo.======================================================================

set OLD_DIR=%CD%
cd %LLVM_OBJ_DIR%

@echo "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %TEST_TARGET_ARCH%
@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %TEST_TARGET_ARCH%

@echo.======================================================================
@echo.Running the Checked C regression tests
@echo.======================================================================

@echo set path="C:\Program Files\Git\usr\bin";%path%
set path="C:\Program Files\Git\usr\bin";%path%

@echo %LLVM_OBJ_DIR%\bin\llvm-lit.py -v %BUILD_SOURCESDIRECTORY%\clang\test\Analysis\diagnostics\sarif-multi-diagnostic-test.c
%LLVM_OBJ_DIR%\bin\llvm-lit.py -v %BUILD_SOURCESDIRECTORY%\clang\test\Analysis\diagnostics\sarif-multi-diagnostic-test.c

goto cmdfailed

@echo ninja -v -j%CL_CPU_COUNT% check-checkedc
ninja -v -j%CL_CPU_COUNT% check-checkedc
if ERRORLEVEL 1 (goto cmdfailed)

if "%TEST_SUITE%"=="CheckedC_LLVM" (
  @echo.======================================================================
  @echo.Running the LLVM/Clang regression tests
  @echo.======================================================================
  @echo ninja -v -j%CL_CPU_COUNT% check-all
  ninja -v -j%CL_CPU_COUNT% check-all
  if ERRORLEVEL 1 (goto cmdfailed)

) else (
  @echo.======================================================================
  @echo.Running the Clang regression tests
  @echo.======================================================================
  @echo ninja -v -j%CL_CPU_COUNT% check-clang
  ninja -v -j%CL_CPU_COUNT% check-clang
  if ERRORLEVEL 1 (goto cmdfailed)
)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  @echo.Unit tests failed
  cd %OLD_DIR%
  exit /b 1
