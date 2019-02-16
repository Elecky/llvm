#ifndef LLVM_LIB_TARGET_NNPU_INSTR_INFO_H
#define LLVM_LIB_TARGET_NNPU_INSTR_INFO_H

#include "NNPURegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "NNPUGenInstrInfo.inc"

namespace llvm {

class NNPUSubtarget;

/// NNPUII - This namespace holds all of the target specific flags that
/// instruction info tracks.
///
namespace NNPUII {
enum {
    Pseudo = (1<<0),
    Load = (1<<1),
    Store = (1<<2),
    DelaySlot = (1<<3)
};
}

class NNPUInstrInfo : public NNPUGenInstrInfo {
    const NNPURegisterInfo RI;
    const NNPUSubtarget& Subtarget;
    virtual void anchor();
public:
    explicit NNPUInstrInfo(NNPUSubtarget &ST);

    /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
    /// such, whenever a client has an instance of instruction info, it should
    /// always be able to get register info as well (through this method).
    ///
    const NNPURegisterInfo &getRegisterInfo() const { return RI; }

    /// isLoadFromStackSlot - If the specified machine instruction is a direct
    /// load from a stack slot, return the virtual or physical register number of
    /// the destination along with the FrameIndex of the loaded stack slot.  If
    /// not, return 0.  This predicate must return 0 if the instruction has
    /// any side effects other than loading from the stack slot.
    // unsigned isLoadFromStackSlot(const MachineInstr &MI,
    //                             int &FrameIndex) const override;

    /// isStoreToStackSlot - If the specified machine instruction is a direct
    /// store to a stack slot, return the virtual or physical register number of
    /// the source reg along with the FrameIndex of the loaded stack slot.  If
    /// not, return 0.  This predicate must return 0 if the instruction has
    /// any side effects other than storing to the stack slot.
    //unsigned isStoreToStackSlot(const MachineInstr &MI,
    //                            int &FrameIndex) const override;

    // bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
    //                    MachineBasicBlock *&FBB,
    //                    SmallVectorImpl<MachineOperand> &Cond,
    //                    bool AllowModify = false) const override
    // {
    //     return true;  // not branch analysis
    // }

    //unsigned removeBranch(MachineBasicBlock &MBB,
    //                        int *BytesRemoved = nullptr) const override;

    unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                           MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                           const DebugLoc &DL,
                           int *BytesAdded = nullptr) const override;

    // bool
    // reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;

    void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                    const DebugLoc &DL, unsigned DestReg, unsigned SrcReg,
                    bool KillSrc) const override;

    void storeRegToStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MBBI,
                            unsigned SrcReg, bool isKill, int FrameIndex,
                            const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI) const override;

    void loadRegFromStackSlot(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                unsigned DestReg, int FrameIndex,
                                const TargetRegisterClass *RC,
                                const TargetRegisterInfo *TRI) const override;

    // unsigned getGlobalBaseReg(MachineFunction *MF) const;

    // Lower pseudo instructions after register allocation.
    // bool expandPostRAPseudo(MachineInstr &MI) const override;
};

}

#endif