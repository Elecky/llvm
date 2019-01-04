//===-- NNPUFrameLowering.h - Define frame lowering for NNPU --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_NNPU_NNPUFRAMELOWERING_H
#define LLVM_LIB_TARGET_NNPU_NNPUFRAMELOWERING_H

#include "NNPU.h"
#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {

class NNPUSubtarget;

class NNPUFrameLowering : public TargetFrameLowering {
public:
    explicit NNPUFrameLowering(const NNPUSubtarget &ST);

    /// emitProlog/emitEpilog - These methods insert prolog and epilog code into
    /// the function.
    void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

    void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

    // MachineBasicBlock::iterator
    // eliminateCallFramePseudoInstr(MachineFunction &MF,
    //                                 MachineBasicBlock &MBB,
    //                                 MachineBasicBlock::iterator I) const override;

    // bool hasReservedCallFrame(const MachineFunction &MF) const override;

    bool hasFP(const MachineFunction &MF) const override 
    { return true; }

    // void determineCalleeSaves(MachineFunction &MF, BitVector &SavedRegs,
    //                             RegScavenger *RS = nullptr) const override;

    // int getFrameIndexReference(const MachineFunction &MF, int FI,
    //                             unsigned &FrameReg) const override;

    /// targetHandlesStackFrameRounding - Returns true if the target is
    /// responsible for rounding up the stack frame (probably at emitPrologue
    /// time).
    bool targetHandlesStackFrameRounding() const override 
    { return false; }

private:

};

} // End llvm namespace

#endif