#ifndef LLVM_LIB_TARGET_NNPU_H
#define LLVM_LIB_TARGET_NNPU_H

#include "MCTargetDesc/NNPUMCTargetDesc.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm
{

  class FunctionPass;
  class NNPUTargetMachine;
  class formatted_raw_ostream;
  class AsmPrinter;
  class MCInst;
  class MachineInstr;

// Target& getTheNNPUTarget();

void LowerNNPUMachineInstrToMCInst(const MachineInstr *MI,
                              MCInst &OutMI,
                              AsmPrinter &AP);

FunctionPass *createNNPUISelDag(NNPUTargetMachine &TM);

}  // end namespace llvm

#endif