#include "NNPUTargetMachine.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/TargetRegistry.h"

namespace llvm
{

extern "C" void LLVMInitializeNNPUTarget() {
  // Register the target.
  RegisterTargetMachine<NNPUTargetMachine> X(getTheNNPUTarget());
}

static Reloc::Model getEffectiveRelocModel(Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

static CodeModel::Model getEffectiveCodeModel(Optional<CodeModel::Model> CM,
                                              Reloc::Model RM,
                                              bool JIT) {
  if (CM)
    return *CM;
  return CodeModel::Small;
}

NNPUTargetMachine::NNPUTargetMachine(
                    const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options,
                    Optional<Reloc::Model> RM, Optional<CodeModel::Model> CM,
                    CodeGenOpt::Level OL, bool JIT)
  : LLVMTargetMachine(
        T, "", TT, CPU, FS, options, 
        getEffectiveRelocModel(RM), 
        getEffectiveCodeModel(CM, getEffectiveRelocModel(RM), JIT), 
        OL),
    Subtarget(TT, CPU, FS, *this)
{
  initAsmInfo();
}


}  // end namespace llvm