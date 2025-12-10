# Build script for Windows PowerShell

param(
    [string]$BuildType = "Release"
)

Write-Host "Building VRCFT-SteamLink for Windows..." -ForegroundColor Blue
Write-Host "Build type: $BuildType" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Join-Path $ScriptDir "SLVRCFT"

# Check and initialize git submodules
Write-Host "[0/3] Checking git submodules..." -ForegroundColor Blue
$vrcftPath = Join-Path $ScriptDir "VRCFaceTracking"
$vrcftCorePath = Join-Path $vrcftPath "VRCFaceTracking.Core"

if (-not (Test-Path (Join-Path $vrcftCorePath "VRCFaceTracking.Core.csproj"))) {
    Write-Host "Initializing git submodules..." -ForegroundColor Yellow
    Push-Location $ScriptDir
    git submodule update --init --recursive
    Pop-Location
}

if (-not (Test-Path (Join-Path $vrcftCorePath "VRCFaceTracking.Core.csproj"))) {
    Write-Host "ERROR: VRCFaceTracking submodule not found. Please run:" -ForegroundColor Red
    Write-Host "  git submodule update --init --recursive" -ForegroundColor Yellow
    exit 1
}
Write-Host "Submodules OK" -ForegroundColor Green

# Find MSBuild for C++ project
$msbuildPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

$msbuild = $null
foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuild = $path
        break
    }
}

if (-not $msbuild) {
    Write-Host "ERROR: MSBuild not found. Please install Visual Studio 2019 or 2022." -ForegroundColor Red
    exit 1
}

Write-Host "Using MSBuild: $msbuild" -ForegroundColor Green

# Step 1: Build C++ native library with MSBuild
Write-Host "[1/3] Building SLOSCParser (C++ native library)..." -ForegroundColor Blue
Push-Location $ProjectRoot
try {
    & $msbuild "SLOSCParser\SLOSCParser.vcxproj" /p:Configuration=$BuildType /p:Platform=x64 /m /v:minimal

    if ($LASTEXITCODE -ne 0) {
        throw "C++ build failed!"
    }
    Write-Host "C++ library built successfully" -ForegroundColor Green
}
finally {
    Pop-Location
}

# Step 2: Copy native library to output directory
Write-Host "[2/3] Copying native libraries..." -ForegroundColor Blue
$nativeLibDir = Join-Path $ProjectRoot "SLExtTrackingModule\bin\$BuildType\net7.0"
$nativeLibSrc = Join-Path $ProjectRoot "SLOSCParser\x64\$BuildType\SLOSCParser.dll"

if (-not (Test-Path $nativeLibDir)) {
    New-Item -ItemType Directory -Path $nativeLibDir -Force | Out-Null
}

if (Test-Path $nativeLibSrc) {
    Copy-Item $nativeLibSrc -Destination $nativeLibDir -Force
    Write-Host "Native library copied from $nativeLibSrc" -ForegroundColor Green
} else {
    # Try alternate location
    $nativeLibSrcAlt = Join-Path $ProjectRoot "x64\$BuildType\SLOSCParser.dll"
    if (Test-Path $nativeLibSrcAlt) {
        Copy-Item $nativeLibSrcAlt -Destination $nativeLibDir -Force
        Write-Host "Native library copied from $nativeLibSrcAlt" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Native library not found at $nativeLibSrc or $nativeLibSrcAlt" -ForegroundColor Yellow
    }
}

# Step 3: Build C# project with dotnet CLI (handles SDK-style projects properly)
Write-Host "[3/3] Building SLExtTrackingModule (C# module)..." -ForegroundColor Blue
Push-Location $ProjectRoot
try {
    dotnet build "SLExtTrackingModule\SLExtTrackingModule.csproj" --configuration $BuildType --verbosity minimal

    if ($LASTEXITCODE -ne 0) {
        throw "C# build failed!"
    }

    # Copy module.json
    $resDir = Join-Path $ProjectRoot "res"
    if (Test-Path $resDir) {
        Copy-Item "$resDir\*" -Destination $nativeLibDir -Force
        Write-Host "Module resources copied" -ForegroundColor Green
    }

    # Install to VRCFaceTracking
    $vrcftCustomLibs = Join-Path $env:APPDATA "VRCFaceTracking\CustomLibs\b146eda9-be48-4016-ab63-680a694064bd"
    if (-not (Test-Path $vrcftCustomLibs)) {
        New-Item -ItemType Directory -Path $vrcftCustomLibs -Force | Out-Null
    }
    Copy-Item "$nativeLibDir\*" -Destination $vrcftCustomLibs -Recurse -Force

    Write-Host ""
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output directory: $nativeLibDir"
    Write-Host ""
    Write-Host "The module has been copied to:"
    Write-Host "  $vrcftCustomLibs"
}
finally {
    Pop-Location
}
