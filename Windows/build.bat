@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
set PATH="C:\GnuWin32\bin";%PATH%

@echo.======================================================================
@echo.Configuring and building the Checked C compiler
@echo.======================================================================

if "%BUILD_CHECKEDC_CLEAN%"=="Yes" (
  if exist %LLVM_OBJ_DIR% (
    rmdir /s /q %LLVM_OBJ_DIR%
    if ERRORLEVEL 1 (goto cmdfailed)
  )
)

set OLD_DIR=%CD%
cd %LLVM_OBJ_DIR%

@echo.======================================================================
@echo.Running the configure step
@echo.======================================================================

@echo "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %TEST_TARGET_ARCH%
@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %TEST_TARGET_ARCH%

set EXTRA_FLAGS=
if "%BUILD_PACKAGE%"=="Yes" (
  if "%BUILDCONFIGURATION%"=="Release" (
    set EXTRA_FLAGS=-DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
  )
)

@echo cmake -G Ninja -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=all -DLLVM_USE_CRT_RELEASE=MT -DCMAKE_BUILD_TYPE=%BUILDCONFIGURATION% %EXTRA_FLAGS% %BUILD_SOURCESDIRECTORY%\llvm
cmake -G Ninja -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=all -DLLVM_USE_CRT_RELEASE=MT -DCMAKE_BUILD_TYPE=%BUILDCONFIGURATION% %EXTRA_FLAGS% %BUILD_SOURCESDIRECTORY%\llvm

if ERRORLEVEL 1 (goto cmdfailed)

@echo.======================================================================
@echo.Running the build step
@echo.======================================================================

@echo ninja
ninja
if ERRORLEVEL 1 (goto cmdfailed)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  @echo.Configure or build failed
  cd %OLD_DIR%
  exit /b 1
