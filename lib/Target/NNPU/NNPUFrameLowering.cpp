//===-- NNPUFrameLowering.cpp - NNPU Frame Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the NNPU implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "NNPUFrameLowering.h"
#include "NNPUInstrInfo.h"
#include "NNPUMachineFunctionInfo.h"
#include "NNPUSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

// static cl::opt<bool>
// DisableLeafProc("disable-NNPU-leaf-proc",
//                 cl::init(false),
//                 cl::desc("Disable NNPU leaf procedure optimization."),
//                 cl::Hidden);

NNPUFrameLowering::NNPUFrameLowering(const NNPUSubtarget &ST)
    : TargetFrameLowering(TargetFrameLowering::StackGrowsDown,
                          4, 0, 4) 
{}

void NNPUFrameLowering::emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const
{
    // NNPUMachineFunctionInfo *FuncInfo = MF.getInfo<NNPUMachineFunctionInfo>();

    assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");
    MachineFrameInfo &MFI = MF.getFrameInfo();
    const NNPUSubtarget &Subtarget = MF.getSubtarget<NNPUSubtarget>();
    const NNPUInstrInfo &TII =
        *static_cast<const NNPUInstrInfo *>(Subtarget.getInstrInfo());
    // const NNPURegisterInfo &RegInfo =
    //     *static_cast<const NNPURegisterInfo *>(Subtarget.getRegisterInfo());
    MachineBasicBlock::iterator MBBI = MBB.begin();
    // Debug location must be unknown since the first debug location is used
    // to determine the end of the prologue.
    DebugLoc dl;

    // Get the number of bytes to allocate from the FrameInfo
    int NumBytes = (int) MFI.getStackSize();

    // Update stack size with corrected value.
    MFI.setStackSize(NumBytes);

    BuildMI(MBB, MBBI, dl, TII.get(NNPU::AddIU), NNPU::SP)
        .addReg(NNPU::SP).addImm(-NumBytes);
        
}

void NNPUFrameLowering::emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const
{
    // NNPUMachineFunctionInfo *FuncInfo = MF.getInfo<NNPUMachineFunctionInfo>();
    MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
    const NNPUInstrInfo &TII =
        *static_cast<const NNPUInstrInfo *>(MF.getSubtarget().getInstrInfo());
    DebugLoc dl = MBBI->getDebugLoc();

    MachineFrameInfo &MFI = MF.getFrameInfo();

    int NumBytes = (int) MFI.getStackSize();

    BuildMI(MBB, MBBI, dl, TII.get(NNPU::AddIU), NNPU::SP)
        .addReg(NNPU::SP).addImm(NumBytes);
}