#ifndef LLVM_LIB_TARGET_NNPU_NNPUISELLOWERING_H
#define LLVM_LIB_TARGET_NNPU_NNPUISELLOWERING_H

#include "NNPU.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {
class NNPUSubtarget;

namespace NNPUISD {

enum NodeType : unsigned {
    FIRST_NUMBER = ISD::BUILTIN_OP_END,
    Ret
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
    
    EVT getSetCCResultType(const DataLayout &DL, LLVMContext &Context,
                           EVT VT) const override
    {
        if (!VT.isVector())
            return MVT::i32;
        llvm_unreachable("vector type is not supported");
    }

private:
    SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;

    SDValue lowerIntrinsic_Void(SDValue Op, SelectionDAG &DAG) const;
};

} // end namespace llvm

#endif