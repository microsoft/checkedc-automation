@echo off

@setlocal
@call checkedc-automation\Windows\config-vars.bat
if ERRORLEVEL 1 (goto cmdfailed)

rem Set path to Unix utilities.
set PATH="C:\Program Files\Git\usr\bin";%PATH%

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

if "%BUILD_PACKAGE%"=="Yes" (
  if "%BUILDCONFIGURATION%"=="Release" (
    set EXTRA_FLAGS=-DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
  ) else (
    set EXTRA_FLAGS=
  )
) else (
  set EXTRA_FLAGS=
)

if "%BUILDCONFIGURATION%"=="Release" (
  set EXTRA_FLAGS=%EXTRA_FLAGS% -DLLVM_USE_CRT_RELEASE=MT
) else (
  set EXTRA_FLAGS=%EXTRA_FLAGS% -DLLVM_USE_CRT_DEBUG=MTd
)

@echo cmake -G Ninja -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=all -DCMAKE_BUILD_TYPE=%BUILDCONFIGURATION% %EXTRA_FLAGS% %BUILD_SOURCESDIRECTORY%\llvm
cmake -G Ninja -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD=all -DCMAKE_BUILD_TYPE=%BUILDCONFIGURATION% %EXTRA_FLAGS% %BUILD_SOURCESDIRECTORY%\llvm

if ERRORLEVEL 1 (goto cmdfailed)

@echo.======================================================================
@echo.Running the build step
@echo.======================================================================

if "%BUILD_PACKAGE%"=="Yes" (
  @echo ninja -j%CL_CPU_COUNT%
  ninja -j%CL_CPU_COUNT%
) else if "%TEST_SUITE%"=="CheckedC_LLVM" (
  @echo ninja -j%CL_CPU_COUNT%
  ninja -j%CL_CPU_COUNT%
) else (
  @echo ninja -j%CL_CPU_COUNT% clang
  ninja -j%CL_CPU_COUNT% clang
)

if ERRORLEVEL 1 (goto cmdfailed)

:succeeded
  cd %OLD_DIR%
  exit /b 0

:cmdfailed
  @echo.Configure or build failed
  cd %OLD_DIR%
  exit /b 1
