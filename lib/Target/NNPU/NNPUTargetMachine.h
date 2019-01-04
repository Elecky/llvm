#ifndef LLVM_LIB_TARGET_NNPU_TARGET_MACHINE_H
#define LLVM_LIB_TARGET_NNPU_TARGET_MACHINE_H

#include "NNPUInstrInfo.h"
#include "NNPUSubtarget.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class NNPUTargetMachine : public LLVMTargetMachine {
    std::unique_ptr<TargetLoweringObjectFile> TLOF;
    NNPUSubtarget Subtarget;

public:
    NNPUTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                      StringRef FS, const TargetOptions &Options,
                      Optional<Reloc::Model> RM, Optional<CodeModel::Model> CM,
                      CodeGenOpt::Level OL, bool JIT);
    ~NNPUTargetMachine() override;

    const NNPUSubtarget *getSubtargetImpl() const { return &Subtarget; }
    const NNPUSubtarget *getSubtargetImpl(const Function &) const override;

    // Pass Pipeline Configuration
    TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

    TargetLoweringObjectFile *getObjFileLowering() const override {
      return TLOF.get();
    }

    bool isMachineVerifierClean() const override {
        return false;
    }
};

}  // end namespace llvm

#endif