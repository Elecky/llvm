//===-- NNPUAsmPrinter.cpp - NNPU LLVM assembly writer ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format NNPU assembly language.
//
//===----------------------------------------------------------------------===//

#include "InstPrinter/NNPUInstPrinter.h"
#include "NNPU.h"
#include "NNPUInstrInfo.h"
#include "NNPUTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCStreamer.h"
// using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace llvm{
class NNPUAsmPrinter : public AsmPrinter {

public:
    explicit NNPUAsmPrinter(TargetMachine &TM,
                             std::unique_ptr<MCStreamer> Streamer)
        : AsmPrinter(TM, std::move(Streamer)) {}

    StringRef getPassName() const override { return "NNPU Assembly Printer"; }

    // void printOperand(const MachineInstr *MI, int opNum, raw_ostream &OS);
    // void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &OS,
    //                      const char *Modifier = nullptr);

    void EmitFunctionEntryLabel() override;
    //void EmitFunctionBodyStart() override;
    
    void EmitInstruction(const MachineInstr *MI) override;

    static const char *getRegisterName(unsigned RegNo) {
      return NNPUInstPrinter::getRegisterName(RegNo);
    }

    // bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
    //                      unsigned AsmVariant, const char *ExtraCode,
    //                      raw_ostream &O) override;
    // bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
    //                            unsigned AsmVariant, const char *ExtraCode,
    //                            raw_ostream &O) override;
};

void NNPUAsmPrinter::EmitInstruction(const MachineInstr *MI)
{
    switch (MI->getOpcode()) {
    default: break;

    case TargetOpcode::DBG_VALUE:
        // FIXME: Debug Value.
        return;
    }

    MachineBasicBlock::const_instr_iterator I = MI->getIterator();
    MachineBasicBlock::const_instr_iterator E = MI->getParent()->instr_end();
    do {
        MCInst TmpInst;
        LowerNNPUMachineInstrToMCInst(&*I, TmpInst, *this);
        EmitToStreamer(*OutStreamer, TmpInst);
    } while ((++I != E) && I->isInsideBundle()); // Delay slot check.
}

void NNPUAsmPrinter::EmitFunctionEntryLabel()
{
    OutStreamer->EmitLabel(CurrentFnSym);
}

} // end of anonymous namespace

using namespace llvm;

extern "C" void LLVMInitializeNNPUAsmPrinter() {
    RegisterAsmPrinter<NNPUAsmPrinter> X(getTheNNPUTarget());
}