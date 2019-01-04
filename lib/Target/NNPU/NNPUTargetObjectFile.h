#ifndef LLVM_LIB_TARGET_NNPU_NNPUTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_NNPU_NNPUTARGETOBJECTFILE_H

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {

class MCContext;
class TargetMachine;

class NNPUELFTargetObjectFile : public TargetLoweringObjectFileELF {
public:
    NNPUELFTargetObjectFile() :
        TargetLoweringObjectFileELF()
    {}

    void Initialize(MCContext &Ctx, const TargetMachine &TM) override;

    // const MCExpr *getTTypeGlobalReference(const GlobalValue *GV,
    //                                         unsigned Encoding,
    //                                         const TargetMachine &TM,
    //                                         MachineModuleInfo *MMI,
    //                                         MCStreamer &Streamer) const override;
};

} // end namespace llvm

#endif