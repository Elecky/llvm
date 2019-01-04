//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// NNPU Subtarget features.
//
// No Subtarget feature at present.


//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "NNPURegisterInfo.td"
include "NNPUCallingConv.td"
//include "NNPUSchedule.td"
include "NNPUInstrInfo.td"

def NNPUInstrInfo : InstrInfo;

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic",         []>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def NNPUAsmWriter : AsmWriter {
  string AsmWriterClassName  = "InstPrinter";
  int PassSubtarget = 1;
  int Variant = 0;
}

def NNPU : Target {
  // Pull in Instruction Info:
  let InstructionSet = NNPUInstrInfo;
  //let AssemblyParsers  = [NNPUAsmParser];
  let AssemblyWriters = [NNPUAsmWriter];
  let AllowRegisterRenaming = 1;
}