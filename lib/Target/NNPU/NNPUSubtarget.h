#ifndef LLVM_LIB_TARGET_NNPU_SUBTARGET_H
#define LLVM_LIB_TARGET_NNPU_SUBTARGET_H

#include "NNPUInstrInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "NNPUGenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class NNPUSubtarget : public NNPUGenSubtargetInfo {
  Triple TargetTriple;
  virtual void anchor();
  
  NNPUInstrInfo InstrInfo;
  // NNPUTargetLowering TLInfo;
  SelectionDAGTargetInfo TSInfo;
  NNPUFrameLowering FrameLowering;

public:
  NNPUSubtarget(const Triple &TT, const std::string &CPU,
                const std::string &FS, const TargetMachine &TM);

  const NNPUInstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const TargetFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const NNPURegisterInfo *getRegisterInfo() const override {
    return &InstrInfo.getRegisterInfo();
  }
  // const NNPUTargetLowering *getTargetLowering() const override {
  //   return &TLInfo;
  // }
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }

  bool enableMachineScheduler() const override;

};

}  // end namespace llvm

#endif