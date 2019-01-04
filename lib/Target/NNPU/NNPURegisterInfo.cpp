//===-- NNPURegisterInfo.cpp - NNPU Register Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the NNPU implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "NNPURegisterInfo.h"
#include "NNPU.h"
#include "NNPUSubtarget.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_REGINFO_TARGET_DESC
#include "NNPUGenRegisterInfo.inc"

/*
static cl::opt<bool>
ReserveAppRegisters("NNPU-reserve-app-registers", cl::Hidden, cl::init(false),
                    cl::desc("Reserve application registers (%g2-%g4)"));
*/

NNPURegisterInfo::NNPURegisterInfo() : NNPUGenRegisterInfo(NNPU::G3) {}

const MCPhysReg *
NNPURegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
    return CSR_SaveList;
}

const uint32_t *
NNPURegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID CC) const {
    return CSR_RegMask;
}

BitVector NNPURegisterInfo::getReservedRegs(const MachineFunction &MF) const {
    static const uint16_t reservedRegs[] = {
            NNPU::Zero, NNPU::SP, NNPU::FP
        };

    BitVector reserved(getNumRegs());

    for (std::size_t i = 0; i < array_lengthof(reservedRegs); ++i)
    {
        reserved.set(reservedRegs[i]);
    }

    return reserved;
}

const TargetRegisterClass *
NNPURegisterInfo::getPointerRegClass(const MachineFunction &MF,
                                     unsigned Kind) const {
    return &NNPU::Int32RegsRegClass;
}

bool NNPURegisterInfo::isConstantPhysReg(unsigned PhysReg) const
{
    return PhysReg == NNPU::Zero;
}

void NNPURegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                           int SPAdj, unsigned FIOperandNum,
                                           RegScavenger *RS) const {
    MachineInstr &MI = *II;
    DebugLoc dl = MI.getDebugLoc();
    int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
    MachineFunction &MF = *MI.getParent()->getParent();
    const NNPUSubtarget &Subtarget = MF.getSubtarget<NNPUSubtarget>();

    unsigned FrameReg = NNPU::FP;
    int Offset;
    Offset = MF.getFrameInfo().getObjectOffset(FrameIndex);
    Offset += MI.getOperand(FIOperandNum + 1).getImm();

    MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false);
    MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

unsigned NNPURegisterInfo::getFrameRegister(const MachineFunction &MF) const {
    return NNPU::FP;
}

bool NNPURegisterInfo::canRealignStack(const MachineFunction &MF) const {
    if (!TargetRegisterInfo::canRealignStack(MF))
        return false;

    return false;
}
