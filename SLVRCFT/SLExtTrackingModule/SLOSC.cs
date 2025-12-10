using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SLExtTrackingModule
{
    enum XrFBWeights : int
    {
        BrowLowererL,
        BrowLowererR,
        CheekPuffL,
        CheekPuffR,
        CheekRaiserL,
        CheekRaiserR,
        CheekSuckL,
        CheekSuckR,
        ChinRaiserB,
        ChinRaiserT,
        DimplerL,
        DimplerR,
        EyesClosedL,
        EyesClosedR,
        EyesLookDownL,
        EyesLookDownR,
        EyesLookLeftL,
        EyesLookLeftR,
        EyesLookRightL,
        EyesLookRightR,
        EyesLookUpL,
        EyesLookUpR,
        InnerBrowRaiserL,
        InnerBrowRaiserR,
        JawDrop,
        JawSidewaysLeft,
        JawSidewaysRight,
        JawThrust,
        LidTightenerL,
        LidTightenerR,
        LipCornerDepressorL,
        LipCornerDepressorR,
        LipCornerPullerL,
        LipCornerPullerR,
        LipFunnelerLB,
        LipFunnelerLT,
        LipFunnelerRB,
        LipFunnelerRT,
        LipPressorL,
        LipPressorR,
        LipPuckerL,
        LipPuckerR,
        LipStretcherL,
        LipStretcherR,
        LipSuckLB,
        LipSuckLT,
        LipSuckRB,
        LipSuckRT,
        LipTightenerL,
        LipTightenerR,
        LipsToward,
        LowerLipDepressorL,
        LowerLipDepressorR,
        MouthLeft,
        MouthRight,
        NoseWrinklerL,
        NoseWrinklerR,
        OuterBrowRaiserL,
        OuterBrowRaiserR,
        UpperLidRaiserL,
        UpperLidRaiserR,
        UpperLipRaiserL,
        UpperLipRaiserR,
        ToungeTipInterdental,
        FBToungeTipAlveolar,
        FrontDorsalPalate,
        MidDorsalPalate,
        BackDorsalVelar,
        FBToungeOut,
        ToungeRetreat,
        XR_FB_WEIGHTS_MAX,
    };

    unsafe struct SLOSCPacket
    {
        public fixed float vEyeGazePoint[3];
        public fixed float vWeights[(int)XrFBWeights.XR_FB_WEIGHTS_MAX];
    }

    internal static class SLOSC
    {
        private const string LibraryName = "SLOSCParser";

        static SLOSC()
        {
            NativeLibrary.SetDllImportResolver(typeof(SLOSC).Assembly, DllImportResolver);
        }

        private static IntPtr DllImportResolver(string libraryName, Assembly assembly, DllImportSearchPath? searchPath)
        {
            if (libraryName == LibraryName)
            {
                // Try platform-specific names
                string[] candidates;
                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    candidates = new[] { "SLOSCParser.dll", "SLOSCParser" };
                }
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                {
                    candidates = new[] { "libSLOSCParser.so", "SLOSCParser.so", "SLOSCParser" };
                }
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                {
                    candidates = new[] { "libSLOSCParser.dylib", "SLOSCParser.dylib", "SLOSCParser" };
                }
                else
                {
                    candidates = new[] { libraryName };
                }

                foreach (var candidate in candidates)
                {
                    if (NativeLibrary.TryLoad(candidate, assembly, searchPath, out IntPtr handle))
                    {
                        return handle;
                    }
                }
            }

            // Fall back to default resolution
            return IntPtr.Zero;
        }

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private extern static unsafe int SLOSCInit(int nInPort, int nOutPort);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private extern static unsafe int SLOSCPollNext(SLOSCPacket* pPacket);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private extern static unsafe int SLOSCClose();

        public static int Init(int nInPort, int nOutPort)
        {
            return SLOSCInit(nInPort, nOutPort);
        }

        public static int PollNext(ref SLOSCPacket packet)
        {
            unsafe
            {
                fixed (SLOSCPacket* pPacket = &packet)
                {
                    return SLOSCPollNext(pPacket);
                }
            }
        }

        public static int Close()
        {
            return SLOSCClose();
        }
    }
}
