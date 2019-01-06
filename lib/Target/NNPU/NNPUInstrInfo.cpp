#include "NNPUInstrInfo.h"
#include "NNPU.h"
#include "NNPUMachineFunctionInfo.h"
#include "NNPUSubtarget.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "NNPUGenInstrInfo.inc"

// Pin the vtable to this file.
void NNPUInstrInfo::anchor() {}

NNPUInstrInfo::NNPUInstrInfo(NNPUSubtarget &ST) :
    RI(),
    Subtarget(ST)
{}

void NNPUInstrInfo::
storeRegToStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                    unsigned SrcReg, bool isKill, int FI,
                    const TargetRegisterClass *RC,
                    const TargetRegisterInfo *TRI) const {
    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();

    MachineFunction *MF = MBB.getParent();
    const MachineFrameInfo &MFI = MF->getFrameInfo();
    MachineMemOperand *MMO = MF->getMachineMemOperand(
        MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOStore,
        MFI.getObjectSize(FI), MFI.getObjectAlignment(FI));

    // On the order of operands here: think "[FrameIdx + 0] = SrcReg".
    if (RC == &NNPU::Int32RegsRegClass)
        BuildMI(MBB, I, DL, get(NNPU::Store)).addFrameIndex(FI).addImm(0)
        .addReg(SrcReg, getKillRegState(isKill)).addMemOperand(MMO);
    else
        llvm_unreachable("Can't store this register to stack slot");
}

void NNPUInstrInfo::
loadRegFromStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                     unsigned DestReg, int FI,
                     const TargetRegisterClass *RC,
                     const TargetRegisterInfo *TRI) const {
    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();

    MachineFunction *MF = MBB.getParent();
    const MachineFrameInfo &MFI = MF->getFrameInfo();
    MachineMemOperand *MMO = MF->getMachineMemOperand(
        MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOLoad,
        MFI.getObjectSize(FI), MFI.getObjectAlignment(FI));

    if (RC == &NNPU::Int32RegsRegClass)
        BuildMI(MBB, I, DL, get(NNPU::Load), DestReg).addFrameIndex(FI).addImm(0)
        .addMemOperand(MMO);
    else
        llvm_unreachable("Can't load this register from stack slot");
}

unsigned NNPUInstrInfo::
    insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                 MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                 const DebugLoc &DL,
                 int *BytesAdded) const
{
    assert(TBB && "insertBranch must not be told to insert a fallthrough");
    assert(Cond.size() == 0 &&
           "NNPUInstrInfo::insertBranch only handles tail merging, "
           "it inserts only unconditional branch");
    assert(!BytesAdded && "code size not handled");

    if (Cond.empty()) {
        assert(!FBB && "Unconditional branch with multiple successors!");
        BuildMI(&MBB, DL, get(NNPU::Jump)).addMBB(TBB);
        return 1;
    }

    llvm_unreachable("conditional branch insert is not handled");
}