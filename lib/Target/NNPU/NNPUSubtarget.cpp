#include "NNPUSubtarget.h"
#include "NNPU.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "NNPU-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "NNPUGenSubtargetInfo.inc"

void NNPUSubtarget::anchor() { }

NNPUSubtarget::NNPUSubtarget(const Triple &TT, const std::string &CPU,
                const std::string &FS, const TargetMachine &TM)
    :   NNPUGenSubtargetInfo(TT, CPU, FS), 
        TargetTriple(TT),
        InstrInfo(initializeSubtargetDependencies(CPU, FS)),
        TLInfo(TM, *this),
        FrameLowering(*this) 
{}

bool NNPUSubtarget::enableMachineScheduler() const {
    return true;
}

NNPUSubtarget& NNPUSubtarget::initializeSubtargetDependencies(StringRef CPU, StringRef FS)
{
    ParseSubtargetFeatures(CPU, FS);
    return *this;
}