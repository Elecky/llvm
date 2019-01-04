#include "NNPUTargetMachine.h"
#include "NNPUTargetObjectFile.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

extern "C" void LLVMInitializeNNPUTarget() {
    // Register the target.
    RegisterTargetMachine<NNPUTargetMachine> X(getTheNNPUTarget());
}

namespace llvm
{

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
          T, "e-p:32:32-i32:32", TT, CPU, FS, Options, 
          getEffectiveRelocModel(RM), 
          getEffectiveCodeModel(CM, getEffectiveRelocModel(RM), JIT), 
          OL),
      TLOF(make_unique<NNPUELFTargetObjectFile>()),
      Subtarget(TT, CPU, FS, *this)
{
    initAsmInfo();
}

const NNPUSubtarget *NNPUTargetMachine::getSubtargetImpl(const Function &) const
{
    return &Subtarget;
}

namespace {

/// NNPU Code Generator Pass Configuration Options.
class NNPUPassConfig : public TargetPassConfig {
public:
    NNPUPassConfig(NNPUTargetMachine &TM, PassManagerBase &PM)
        : TargetPassConfig(TM, PM) {}

    NNPUTargetMachine &getNNPUTargetMachine() const {
        return getTM<NNPUTargetMachine>();
    }

    void addIRPasses() override;
    bool addInstSelector() override;
    // void addPreEmitPass() override;
};

void NNPUPassConfig::addIRPasses() {
    TargetPassConfig::addIRPasses();
}

bool NNPUPassConfig::addInstSelector() {
    addPass(createNNPUISelDag(getNNPUTargetMachine()));
    return false;
}

// void NNPUPassConfig::addPreEmitPass(){
//   addPass(createNNPUDelaySlotFillerPass());

//   if (this->getNNPUTargetMachine().getSubtargetImpl()->insertNOPLoad())
//   {
//     addPass(new InsertNOPLoad());
//   }
//   if (this->getNNPUTargetMachine().getSubtargetImpl()->detectRoundChange()) {
//     addPass(new DetectRoundChange());
//   }
//   if (this->getNNPUTargetMachine().getSubtargetImpl()->fixAllFDIVSQRT())
//   {
//     addPass(new FixAllFDIVSQRT());
//   }
// }

} // namespace

TargetPassConfig *NNPUTargetMachine::createPassConfig(PassManagerBase &PM) {
    return new NNPUPassConfig(*this, PM);
}

NNPUTargetMachine::~NNPUTargetMachine() = default;


}  // end namespace llvm