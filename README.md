# SteamLink Module for VRCFT

> **Note:** This is a fork of [danwillm/VRCFT-SteamLink](https://github.com/danwillm/VRCFT-SteamLink) with added Linux support. All credit for the original implementation goes to [danwillm](https://github.com/danwillm).

This repository contains an example of how to use the experimental OSC data from the Steam Link SteamVR driver for face and eye tracking with VRCFT.

The module has support for eye and face tracking.

You **must** set the OSC Port in SteamLink SteamVR Settings to "Custom" for data to be sent. (SteamVR Settings > SteamLink > OSC Port)

## About OSC data from SteamLink

When using "Custom" output from SteamLink (SteamVR Settings > SteamLink > OSC Port), OSC data is sent on port 9015. A list of all addresses sent is listed below:

Eye Tracking:

```
/sl/eyeTrackedGazePoint - 3 floats, representing a 3d point in space the user is looking at

/avatar/parameters/LeftEyeX
/avatar/parameters/LeftEyeY
/avatar/parameters/RightEyeX
/avatar/parameters/RightEyeY
/tracking/eye/CenterVecFull
/avatar/parameters/RightEyeLid
/avatar/parameters/RightEyeLidExpandedSqueeze
/avatar/parameters/RightEyeSqueezeToggle
/avatar/parameters/RightEyeWidenToggle
/avatar/parameters/LeftEyeLid
/avatar/parameters/LeftEyeLidExpandedSqueeze
/avatar/parameters/LeftEyeSqueezeToggle
/avatar/parameters/LeftEyeWidenToggle
/tracking/eye/EyesClosedAmount
```

OpenXR Face Tracking:
```
/sl/xrfb/facec/LowerFace
/sl/xrfb/facec/UpperFace
/sl/xrfb/facew/BrowLowererL
/sl/xrfb/facew/BrowLowererR
/sl/xrfb/facew/CheekPuffL
/sl/xrfb/facew/CheekPuffR
/sl/xrfb/facew/CheekRaiserL
/sl/xrfb/facew/CheekRaiserR
/sl/xrfb/facew/CheekSuckL
/sl/xrfb/facew/CheekSuckR
/sl/xrfb/facew/ChinRaiserB
/sl/xrfb/facew/ChinRaiserT
/sl/xrfb/facew/DimplerL
/sl/xrfb/facew/DimplerR
/sl/xrfb/facew/EyesClosedL
/sl/xrfb/facew/EyesClosedR
/sl/xrfb/facew/EyesLookDownL
/sl/xrfb/facew/EyesLookDownR
/sl/xrfb/facew/EyesLookLeftL
/sl/xrfb/facew/EyesLookLeftR
/sl/xrfb/facew/EyesLookRightL
/sl/xrfb/facew/EyesLookRightR
/sl/xrfb/facew/EyesLookUpL
--- BUNDLE
/sl/xrfb/facew/EyesLookUpR
/sl/xrfb/facew/InnerBrowRaiserL
/sl/xrfb/facew/InnerBrowRaiserR
/sl/xrfb/facew/JawDrop
/sl/xrfb/facew/JawSidewaysLeft
/sl/xrfb/facew/JawSidewaysRight
/sl/xrfb/facew/JawThrust
/sl/xrfb/facew/LidTightenerL
/sl/xrfb/facew/LidTightenerR
/sl/xrfb/facew/LipCornerDepressorL
/sl/xrfb/facew/LipCornerDepressorR
/sl/xrfb/facew/LipCornerPullerL
/sl/xrfb/facew/LipCornerPullerR
/sl/xrfb/facew/LipFunnelerLB
/sl/xrfb/facew/LipFunnelerLT
/sl/xrfb/facew/LipFunnelerRB
/sl/xrfb/facew/LipFunnelerRT
/sl/xrfb/facew/LipPressorL
/sl/xrfb/facew/LipPressorR
/sl/xrfb/facew/LipPuckerL
---BUNDLE
/sl/xrfb/facew/LipPuckerR
/sl/xrfb/facew/LipStretcherL
/sl/xrfb/facew/LipStretcherR
/sl/xrfb/facew/LipSuckLB
/sl/xrfb/facew/LipSuckLT
/sl/xrfb/facew/LipSuckRB
/sl/xrfb/facew/LipSuckRT
/sl/xrfb/facew/LipTightenerL
/sl/xrfb/facew/LipTightenerR
/sl/xrfb/facew/LipsToward
/sl/xrfb/facew/LowerLipDepressorL
/sl/xrfb/facew/LowerLipDepressorR
/sl/xrfb/facew/MouthLeft
/sl/xrfb/facew/MouthRight
/sl/xrfb/facew/NoseWrinklerL
/sl/xrfb/facew/NoseWrinklerR
/sl/xrfb/facew/OuterBrowRaiserL
/sl/xrfb/facew/OuterBrowRaiserR
/sl/xrfb/facew/UpperLidRaiserL
/sl/xrfb/facew/UpperLidRaiserR
/sl/xrfb/facew/UpperLipRaiserL
/sl/xrfb/facew/UpperLipRaiserR
---BUNDLE
/sl/xrfb/facew/TongueTipInterdental
/sl/xrfb/facew/TongueTipAlveolar
/sl/xrfb/facew/FrontDorsalPalate
/sl/xrfb/facew/MidDorsalPalate
/sl/xrfb/facew/BackDorsalVelar
/sl/xrfb/facew/TongueOut
/sl/xrfb/facew/TongueRetreat
```

Addresses may be sent in different bundles. How different addresses are packaged are noted by `---BUNDLE` above.

## Building the Module

This module supports both Windows and Linux platforms.

### Prerequisites

**Windows:**
- Visual Studio 2019 or 2022 with C++ and .NET 7.0 support
- .NET 7.0 SDK

**Linux:**
- GCC or Clang compiler with C++17 support
- CMake 3.15 or higher
- .NET 7.0 SDK
- Build essentials: `sudo apt install build-essential cmake`

### Build Instructions

#### Linux

1. Clone the repository with submodules:
   ```bash
   git clone --recursive https://github.com/danwillm/VRCFT-SteamLink.git
   cd VRCFT-SteamLink
   ```

2. Run the build script:
   ```bash
   chmod +x build-linux.sh
   ./build-linux.sh Release
   ```

3. The module will be automatically installed to:
   ```
   ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd
   ```

#### Windows

1. Clone the repository with submodules:
   ```powershell
   git clone --recursive https://github.com/danwillm/VRCFT-SteamLink.git
   cd VRCFT-SteamLink
   ```

2. Run the build script (PowerShell):
   ```powershell
   .\build-windows.ps1 -BuildType Release
   ```

   Or use the batch file:
   ```cmd
   build-windows.bat Release
   ```

3. The module will be automatically installed to:
   ```
   %AppData%\VRCFaceTracking\CustomLibs\b146eda9-be48-4016-ab63-680a694064bd
   ```

### Manual Build

If you prefer to build manually:

1. **Build the native C++ library:**
   ```bash
   cd SLVRCFT/SLOSCParser
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

2. **Copy the native library:**
   - Linux: Copy `lib/libSLOSCParser.so` to `SLVRCFT/SLExtTrackingModule/bin/Release/net7.0/`
   - Windows: The Visual Studio build handles this automatically

3. **Build the C# module:**
   ```bash
   cd SLVRCFT
   dotnet build SLExtTrackingModule/SLExtTrackingModule.csproj --configuration Release
   ```

### Development Notes

- The C++ native library (`SLOSCParser`) handles OSC message parsing
- The C# module (`SLExtTrackingModule`) integrates with VRCFaceTracking
- On Linux, the native library is built with CMake instead of MSBuild
- Socket library differences are handled automatically (ws2_32 on Windows, pthreads on Linux)
