# VRCFT-SteamLink Build System

## Project Structure

```
VRCFT-SteamLink/
├── CMakeLists.txt                    # Root CMake configuration
├── build-linux.sh                     # Linux build script
├── build-windows.bat                  # Windows batch build script
├── build-windows.ps1                  # Windows PowerShell build script
├── SLVRCFT/
│   ├── SLVRCFT.sln                   # Visual Studio solution (Windows)
│   ├── res/
│   │   └── module.json               # Module metadata
│   ├── SLOSCParser/                  # C++ Native Library
│   │   ├── CMakeLists.txt           # CMake build configuration
│   │   ├── SLOSCParser.vcxproj      # Visual Studio project (Windows)
│   │   ├── sloscparser.cpp
│   │   ├── sloscparser.h
│   │   └── miniosc.h
│   └── SLExtTrackingModule/          # C# Module
│       ├── SLExtTrackingModule.csproj
│       ├── SLExtTrackingModule.cs
│       └── SLOSC.cs                  # P/Invoke wrapper
└── VRCFaceTracking/                  # Submodule dependency
```

## Components

### 1. SLOSCParser (C++ Native Library)

**Purpose:** Parses OSC (Open Sound Control) messages from SteamLink

**Platform Support:**
- **Windows:** Built with MSVC via Visual Studio project
- **Linux:** Built with GCC/Clang via CMake

**Dependencies:**
- Windows: `ws2_32.lib` (Winsock)
- Linux: `pthread` (POSIX threads)

**Output:**
- Windows: `SLOSCParser.dll`
- Linux: `libSLOSCParser.so`

### 2. SLExtTrackingModule (C# .NET Module)

**Purpose:** VRCFaceTracking module that interfaces with the native library

**Framework:** .NET 7.0

**Dependencies:**
- VRCFaceTracking.Core (via submodule)
- SLOSCParser native library (P/Invoke)

**Output:** `SLExtTrackingModule.dll`

## Build Process

### Linux Build Process

1. **Build Native Library:**
   ```bash
   cd SLVRCFT/SLOSCParser
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```
   Output: `lib/libSLOSCParser.so`

2. **Copy Native Library:**
   ```bash
   cp lib/libSLOSCParser.so ../../SLExtTrackingModule/bin/Release/net7.0/
   ```

3. **Build C# Module:**
   ```bash
   cd ../../
   dotnet build SLExtTrackingModule/SLExtTrackingModule.csproj --configuration Release
   ```

4. **Install Module:**
   ```bash
   cp -r SLExtTrackingModule/bin/Release/net7.0/* \
     ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd/
   ```

### Windows Build Process

1. **Build with Visual Studio:**
   ```powershell
   MSBuild SLVRCFT.sln /p:Configuration=Release /p:Platform=x64
   ```
   - Builds both C++ and C# projects
   - Automatically copies outputs to correct locations

2. **Post-Build Events:**
   - Copies native DLL to C# output directory
   - Copies module metadata
   - Installs to `%AppData%\VRCFaceTracking\CustomLibs\...`

## Platform-Specific Considerations

### Native Library Loading

The C# code uses `RuntimeInformation.IsOSPlatform()` to determine the correct library name:
- Windows: `SLOSCParser.dll`
- Linux: `libSLOSCParser.so`

### Socket APIs

The C++ code uses conditional compilation:
- Windows: Winsock2 (`winsock2.h`, `ws2_32.lib`)
- Linux: Berkeley sockets (`sys/socket.h`, `netinet/in.h`)

### File Paths

Module installation paths differ by platform:
- Windows: `%AppData%\VRCFaceTracking\CustomLibs\<module-id>`
- Linux: `~/.local/share/VRCFaceTracking/CustomLibs\<module-id>`

## Troubleshooting

### Linux: Library Not Found

If you get "cannot open shared object file" errors:

1. Ensure the `.so` file is in the same directory as the `.dll`
2. Check library permissions: `chmod +x libSLOSCParser.so`
3. Add to library path if needed:
   ```bash
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)
   ```

### Windows: Missing Visual C++ Runtime

Install the Visual C++ Redistributable matching your Visual Studio version.

### Build Errors: Missing Dependencies

Ensure all git submodules are initialized:
```bash
git submodule update --init --recursive
```

## Development Workflow

### Adding New OSC Parameters

1. Update `sloscparser.h` - Add enum value
2. Update `sloscparser.cpp` - Add to mapping
3. Update `SLOSC.cs` - Add to C# enum
4. Update `SLExtTrackingModule.cs` - Handle new parameter
5. Rebuild both native and managed components

### Testing

1. **Test Native Library:**
   - Create a simple test app that calls Init/PollNext/Close
   - Verify OSC messages are parsed correctly

2. **Test Module:**
   - Install to VRCFaceTracking CustomLibs directory
   - Launch VRCFaceTracking
   - Verify module loads and processes data

## CI/CD Considerations

For automated builds:

**Linux:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake
wget https://dot.net/v1/dotnet-install.sh
bash dotnet-install.sh --channel 7.0
./build-linux.sh Release
```

**Windows:**
```powershell
# Requires Visual Studio Build Tools or full VS installation
.\build-windows.ps1 -BuildType Release
```

## Module Metadata

The `module.json` file contains:
- `ModuleId`: UUID for the module
- `DllFileName`: Name of the C# assembly
- Version, author, download URLs, etc.

This must be copied to the output directory during build.
