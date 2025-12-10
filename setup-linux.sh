#!/bin/bash
# Initial setup script for Linux development

echo "======================================"
echo "  VRCFT-SteamLink Linux Setup"
echo "======================================"
echo ""

# Check for required tools
echo "Checking prerequisites..."

# Check for git
if ! command -v git &> /dev/null; then
    echo "❌ git is not installed. Please install it: sudo apt install git"
    exit 1
fi
echo "✓ git found"

# Check for cmake
if ! command -v cmake &> /dev/null; then
    echo "❌ cmake is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y cmake
else
    echo "✓ cmake found"
fi

# Check for build tools
if ! command -v g++ &> /dev/null; then
    echo "❌ g++ is not installed. Installing build-essential..."
    sudo apt-get update
    sudo apt-get install -y build-essential
else
    echo "✓ g++ found"
fi

# Check for .NET
if ! command -v dotnet &> /dev/null; then
    echo "⚠️  .NET 7.0 SDK not found"
    echo "Please install from: https://dotnet.microsoft.com/download/dotnet/7.0"
    echo "Or use the Microsoft package repository:"
    echo ""
    echo "  wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
    echo "  sudo dpkg -i packages-microsoft-prod.deb"
    echo "  rm packages-microsoft-prod.deb"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y dotnet-sdk-7.0"
    echo ""
else
    DOTNET_VERSION=$(dotnet --version)
    echo "✓ .NET found (version $DOTNET_VERSION)"
fi

echo ""
echo "Checking git submodules..."

# Initialize submodules if they haven't been
if [ ! -f "VRCFaceTracking/.git" ]; then
    echo "Initializing submodules..."
    git submodule update --init --recursive
else
    echo "✓ Submodules initialized"
fi

echo ""
echo "Making build script executable..."
chmod +x build-linux.sh

echo ""
echo "======================================"
echo "  Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Verify .NET 7.0 SDK is installed: dotnet --version"
echo "  2. Build the project: ./build-linux.sh Release"
echo "  3. The module will be installed to:"
echo "     ~/.local/share/VRCFaceTracking/CustomLibs/b146eda9-be48-4016-ab63-680a694064bd"
echo ""
