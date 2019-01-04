#ifndef LLVM_LIB_TARGET_NNPU_NNPUISELLOWERING_H
#define LLVM_LIB_TARGET_NNPU_NNPUISELLOWERING_H

#include "NNPU.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {
class NNPUSubtarget;

namespace NNPUISD {

enum NodeType : unsigned {
    FIRST_NUMBER = ISD::BUILTIN_OP_END,
    Ret,
    MO_ABS_ALL
};

}  // end namespace NNPUISD

class NNPUTargetLowering : public TargetLowering {
    const NNPUSubtarget *Subtarget;

public:
    NNPUTargetLowering(const TargetMachine &TM, const NNPUSubtarget &STI);
    
    SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

    const char *getTargetNodeName(unsigned Opcode) const override;

    SDValue
    LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                         const SmallVectorImpl<ISD::InputArg> &Ins,
                         const SDLoc &dl, SelectionDAG &DAG,
                         SmallVectorImpl<SDValue> &InVals) const override;

    SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        const SmallVectorImpl<SDValue> &OutVals,
                        const SDLoc &dl, SelectionDAG &DAG) const override;

private:
    SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
};

} // end namespace llvm

#endif