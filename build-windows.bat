@echo off
REM Build script for Windows

setlocal enabledelayedexpansion

echo Building VRCFT-SteamLink for Windows...

REM Configuration
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Release

echo Build type: %BUILD_TYPE%

REM Get script directory
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%SLVRCFT

REM Step 1: Build using MSBuild (builds both C++ and C# projects)
echo [1/2] Building solution...
cd /d "%PROJECT_ROOT%"

REM Try to find MSBuild
set MSBUILD_PATH=
for %%i in (
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
) do (
    if exist %%i (
        set MSBUILD_PATH=%%i
        goto :found_msbuild
    )
)

echo ERROR: MSBuild not found. Please install Visual Studio 2019 or 2022.
exit /b 1

:found_msbuild
echo Using MSBuild: %MSBUILD_PATH%

REM Build the solution
"%MSBUILD_PATH%" SLVRCFT.sln /p:Configuration=%BUILD_TYPE% /p:Platform=x64 /m

if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

echo.
echo Build completed successfully!
echo.
echo Output directory: %PROJECT_ROOT%\SLExtTrackingModule\bin\%BUILD_TYPE%\net7.0
echo.
echo The module has been copied to:
echo   %%AppData%%\VRCFaceTracking\CustomLibs\b146eda9-be48-4016-ab63-680a694064bd

endlocal
