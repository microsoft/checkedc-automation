@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

echo.======================================================================
echo.Running unit tests using lit for the Checked C compiler
echo.======================================================================

set OLD_DIR=%CD%
cd %LLVM_OBJ_DIR%

echo.======================================================================
echo.Running the Checked C regression tests
echo.======================================================================
%BUILDCONFIGURATION%\bin\llvm-lit.py -v %BUILD_SOURCESDIRECTORY%\llvm\projects\checkedc-wrapper\checkedc\tests
if ERRORLEVEL 1 (goto cmdfailed)

echo.======================================================================
echo.Running the Clang regression tests
echo.======================================================================
%BUILDCONFIGURATION%\bin\llvm-lit.py -v %BUILD_SOURCESDIRECTORY%\clang\tests
if ERRORLEVEL 1 (goto cmdfailed)

if "%TEST_SUITE%"=="CheckedC_LLVM" (
  echo.======================================================================
  echo.Running the LLVM regression tests
  echo.======================================================================
  %BUILDCONFIGURATION%\bin\llvm-lit.py -v %BUILD_SOURCESDIRECTORY%\llvm\tests
  if ERRORLEVEL 1 (goto cmdfailed)
)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  echo.Unit tests failed
  cd %OLD_DIR%
  exit /b 1
