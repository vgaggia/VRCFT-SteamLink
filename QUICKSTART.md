# Quick Start Guide - Building VRCFT-SteamLink

## TL;DR

### Linux
```bash
# Prerequisites
sudo apt install build-essential cmake

# Install .NET 7.0 SDK
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-7.0

# Build
git clone --recursive https://github.com/danwillm/VRCFT-SteamLink.git
cd VRCFT-SteamLink
chmod +x build-linux.sh
./build-linux.sh Release
```

### Windows
```powershell
# Prerequisites: Visual Studio 2019/2022 + .NET 7.0 SDK

# Build
git clone --recursive https://github.com/danwillm/VRCFT-SteamLink.git
cd VRCFT-SteamLink
.\build-windows.ps1 -BuildType Release
```

## Linux Installation Details

### Prerequisites

1. **Build tools:**
   ```bash
   sudo apt update
   sudo apt install -y build-essential cmake git
   ```

2. **.NET 7.0 SDK** (choose one method):

   **Option A - Microsoft packages (Ubuntu/Debian):**
   ```bash
   wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   rm packages-microsoft-prod.deb
   sudo apt-get update
   sudo apt-get install -y dotnet-sdk-7.0
   ```

   **Option B - Install script:**
   ```bash
   wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
   chmod +x dotnet-install.sh
   ./dotnet-install.sh --channel 7.0
   export PATH="$HOME/.dotnet:$PATH"
   ```

   **Option C - Snap (Ubuntu):**
   ```bash
   sudo snap install dotnet-sdk --classic --channel=7.0
   ```

3. **Verify .NET installation:**
   ```bash
   dotnet --version
   # Should show 7.x.x
   ```

### Build Steps

```bash
# 1. Clone with submodules
git clone --recursive https://github.com/danwillm/VRCFT-SteamLink.git
cd VRCFT-SteamLink

# 2. Make build script executable
chmod +x build-linux.sh

# 3. Build
./build-linux.sh Release
```

### Where Files Are Installed

The build script automatically installs the module to:
```
~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd/
```

This directory will contain:
- `SLExtTrackingModule.dll` - The main C# module
- `libSLOSCParser.so` - The native OSC parser library
- `VRCFaceTracking.Core.dll` - Core dependency
- `module.json` - Module metadata

### Manual Installation (if needed)

If you need to install manually:
```bash
# Create the module directory
mkdir -p ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd

# Copy all built files
cp SLVRCFT/SLExtTrackingModule/bin/Release/net7.0/* \
   ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd/
```

### Verifying the Installation

1. **Check all required files exist:**
   ```bash
   ls -la ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd/
   ```
   You should see: `SLExtTrackingModule.dll`, `libSLOSCParser.so`, `module.json`

2. **Test native library loads:**
   ```bash
   cd ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd/
   ldd libSLOSCParser.so
   # Should show linked libraries, no "not found" errors
   ```

3. **Launch VRCFaceTracking** and check if the SteamLink module appears

### Linux Troubleshooting

**"libSLOSCParser.so: cannot open shared object file"**
- Ensure the `.so` file is in the same directory as the `.dll`
- Check permissions: `chmod +x libSLOSCParser.so`

**Module doesn't appear in VRCFaceTracking**
- Verify `module.json` exists in the module directory
- Check VRCFaceTracking logs for errors

**Build fails with "cmake not found"**
- Install cmake: `sudo apt install cmake`

**Build fails with "dotnet not found"**
- Install .NET SDK (see prerequisites above)
- If using install script, add to PATH: `export PATH="$HOME/.dotnet:$PATH"`

## What Was Changed for Linux Support

### 1. Native C++ Library Build System
- **Added:** `SLVRCFT/SLOSCParser/CMakeLists.txt`
- CMake configuration for cross-platform builds
- Handles Windows (ws2_32) vs Linux (pthread) dependencies

### 2. Cross-Platform C# Project
- **Modified:** `SLVRCFT/SLExtTrackingModule/SLExtTrackingModule.csproj`
- Separated post-build events for Windows and Linux
- Removed hard dependency on .vcxproj (Windows-only)

### 3. Platform-Aware Native Library Loading
- **Modified:** `SLVRCFT/SLExtTrackingModule/SLOSC.cs`
- Runtime detection of OS platform
- Loads correct library: `SLOSCParser.dll` (Windows) or `libSLOSCParser.so` (Linux)

### 4. Build Scripts
- **Added:** `build-linux.sh` - Automated Linux build
- **Added:** `build-windows.ps1` - PowerShell build script
- **Added:** `build-windows.bat` - Batch file alternative
- **Added:** `CMakeLists.txt` - Root project configuration

### 5. Documentation
- **Updated:** `README.md` - Build instructions for both platforms
- **Added:** `BUILD.md` - Detailed build system documentation
- **Added:** `.github/workflows/build.yml` - CI/CD configuration

## Key Technical Details

### Native Library Differences
| Aspect | Windows | Linux |
|--------|---------|-------|
| Build System | MSBuild (vcxproj) | CMake |
| Compiler | MSVC | GCC/Clang |
| Library Name | SLOSCParser.dll | libSLOSCParser.so |
| Socket Library | ws2_32.lib | POSIX (pthread) |

### Installation Paths
| Platform | Location |
|----------|----------|
| Windows | `%AppData%\VRCFaceTracking\CustomLibs\<module-id>` |
| Linux | `~/.local/share/VRCFaceTracking/CustomLibs/<module-id>` |

## Testing Your Build

1. **Verify native library was built:**
   - Linux: Check for `SLVRCFT/SLOSCParser/build/lib/libSLOSCParser.so`
   - Windows: Check for `SLVRCFT/x64/Release/SLOSCParser.dll`

2. **Verify C# module was built:**
   - Check `SLVRCFT/SLExtTrackingModule/bin/Release/net7.0/SLExtTrackingModule.dll`

3. **Verify native library is in output:**
   - The `.so` or `.dll` should be in the same directory as the C# `.dll`

4. **Test with VRCFaceTracking:**
   - Launch VRCFaceTracking
   - Module should appear in the module list
   - Enable and verify OSC data is received

## Common Issues

### Linux: "libSLOSCParser.so: cannot open shared object file"
**Solution:** Ensure the `.so` file is in the same directory as `SLExtTrackingModule.dll`

### Windows: "Could not load file or assembly"
**Solution:** Install Visual C++ Redistributable for your VS version

### Both: Module doesn't appear in VRCFT
**Solution:** Check that `module.json` was copied to the output directory

## Next Steps

- The build system is now cross-platform ready
- You can develop and test on Linux
- Consider adding Linux-specific OSC optimizations if needed
- Test with actual SteamLink hardware on Linux

## Contributing

When modifying:
- **C++ code:** Test both Windows and Linux builds
- **C# code:** Use `RuntimeInformation` for platform detection
- **Build scripts:** Keep both platform scripts in sync
- **Documentation:** Update both README.md and BUILD.md
