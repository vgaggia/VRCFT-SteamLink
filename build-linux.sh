#!/bin/bash
# Build script for Linux

set -e

echo "Building VRCFT-SteamLink for Linux..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/SLVRCFT"

# Configuration
BUILD_TYPE="${1:-Release}"
echo -e "${BLUE}Build type: $BUILD_TYPE${NC}"

# Check prerequisites
echo -e "${BLUE}[0/4] Checking prerequisites...${NC}"

if ! command -v cmake &> /dev/null; then
    echo -e "${RED}ERROR: cmake is not installed. Install with: sudo apt install cmake${NC}"
    exit 1
fi

if ! command -v g++ &> /dev/null; then
    echo -e "${RED}ERROR: g++ is not installed. Install with: sudo apt install build-essential${NC}"
    exit 1
fi

if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}ERROR: .NET SDK is not installed. Install from: https://dotnet.microsoft.com/download${NC}"
    exit 1
fi

# Check git submodules
VRCFT_CORE="$SCRIPT_DIR/VRCFaceTracking/VRCFaceTracking.Core/VRCFaceTracking.Core.csproj"
if [ ! -f "$VRCFT_CORE" ]; then
    echo -e "${BLUE}Initializing git submodules...${NC}"
    cd "$SCRIPT_DIR"
    git submodule update --init --recursive
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"

# Step 1: Build native C++ library
echo -e "${BLUE}[1/4] Building SLOSCParser (C++ native library)...${NC}"
cd "$PROJECT_ROOT/SLOSCParser"

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

# Build
cmake --build . --config "$BUILD_TYPE"

echo -e "${GREEN}✓ SLOSCParser built successfully${NC}"

# Step 2: Copy native library to output directory
echo -e "${BLUE}[2/4] Copying native libraries...${NC}"
NATIVE_LIB_DIR="$PROJECT_ROOT/SLExtTrackingModule/bin/$BUILD_TYPE/net7.0"
mkdir -p "$NATIVE_LIB_DIR"

# Copy the shared library
if [ -f "libSLOSCParser.so" ]; then
    cp libSLOSCParser.so "$NATIVE_LIB_DIR/"
elif [ -f "lib/libSLOSCParser.so" ]; then
    cp lib/libSLOSCParser.so "$NATIVE_LIB_DIR/"
else
    echo -e "${RED}ERROR: Could not find libSLOSCParser.so${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Native library copied${NC}"

# Step 3: Build C# project
echo -e "${BLUE}[3/4] Building SLExtTrackingModule (C# module)...${NC}"
cd "$PROJECT_ROOT"

dotnet build SLExtTrackingModule/SLExtTrackingModule.csproj \
    --configuration "$BUILD_TYPE" \
    --verbosity minimal

# Copy module.json
if [ -d "res" ]; then
    cp res/* "$NATIVE_LIB_DIR/" 2>/dev/null || true
fi

echo -e "${GREEN}✓ C# module built successfully${NC}"

# Step 4: Install to VRCFaceTracking
echo -e "${BLUE}[4/4] Installing module...${NC}"
INSTALL_DIR="$HOME/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd"
mkdir -p "$INSTALL_DIR"
cp -r "$NATIVE_LIB_DIR"/* "$INSTALL_DIR/"

echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""
echo "Output directory: $NATIVE_LIB_DIR"
echo ""
echo "Module installed to:"
echo "  $INSTALL_DIR"
