//===-- NNPUInstPrinter.cpp - Convert NNPU MCInst to assembly syntax -----==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an NNPU MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "NNPUInstPrinter.h"
#include "NNPU.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/raw_ostream.h"
#include <sstream>
#include <iostream>
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#define GET_INSTRUCTION_NAME
#define PRINT_ALIAS_INSTR
#include "NNPUGenAsmWriter.inc"

void NNPUInstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const
{
    OS << '$' << StringRef(getRegisterName(RegNo)).lower();
}

void NNPUInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                 StringRef Annot, const MCSubtargetInfo &STI) {
    if (!printAliasInstr(MI, STI, O))
        printInstruction(MI, STI, O);
    printAnnotation(O, Annot);
}

void NNPUInstPrinter::printOperand(const MCInst *MI, int opNum,
                                    const MCSubtargetInfo &STI,
                                    raw_ostream &O) {
    const MCOperand &op = MI->getOperand (opNum);
    
    if (op.isReg())
    {
        printRegName(O, op.getReg());
        return;
    }

    if (op.isImm())
    {
        O << op.getImm();
        return;
    }

    if (op.isFPImm())
    {
        // we rely on std::stringstream to output the double value,
        // since llvm::raw_ostream don't distinguish between positive and negative infinity.
        std::stringstream ss;
        ss << op.getFPImm();
        O << ss.str();
        return;
    }

    assert(op.isExpr() && "unknown operand kind in printOperand");

    op.getExpr()->print(O, &MAI, true);
}

void NNPUInstPrinter::printMemOperand(const MCInst *MI, int opNum,
                                       const MCSubtargetInfo &STI,
                                       raw_ostream &O, const char *Modifier) {
    printOperand(MI, opNum + 1, STI, O);
    O << '(';
    printOperand(MI, opNum, STI, O);
    O << ")";
}

void NNPUInstPrinter::printBoolOperand(const MCInst *MI, int opNum, const MCSubtargetInfo &STI,
                        raw_ostream &OS, const char *Modifier)
{
    const MCOperand &op = MI->getOperand(opNum);

    assert(op.isImm() && ", non-immediate operand encountered");
    if (op.getImm() == 0)
    {
        OS << "F";
    }
    else
    {
        OS << "T";
    }
    
}