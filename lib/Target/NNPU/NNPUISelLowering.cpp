#include "NNPUISelLowering.h"
#include "NNPUMachineFunctionInfo.h"
#include "NNPURegisterInfo.h"
#include "NNPUTargetMachine.h"
#include "NNPUTargetObjectFile.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/KnownBits.h"
using namespace llvm;

namespace llvm
{

NNPUTargetLowering::NNPUTargetLowering(const TargetMachine &TM,
                                       const NNPUSubtarget &STI)
    : TargetLowering(TM), Subtarget(&STI) 
{
    MVT PtrVT = MVT::getIntegerVT(8 * TM.getPointerSize(0));

    // addRegisterClass(MVT::i1, &NNPU::Int32RegsRegClass);
    addRegisterClass(MVT::i32, &NNPU::Int32RegsRegClass);

    computeRegisterProperties(Subtarget->getRegisterInfo());

    setOperationAction(ISD::GlobalAddress, PtrVT, Custom);

    //setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1, Expand);
    //setOperationAction(ISD::SIGN_EXTEND, MVT::i1, Expand);
    setOperationAction(ISD::SELECT_CC, MVT::i32, Expand);
    //setOperationAction(ISD::SELECT, MVT::i32, Expand);
    setOperationAction(ISD::BR_CC, MVT::i32, Expand);

    // the SDOps which needs promote. 
    static const decltype(ISD::ADD) promoteSDs[] = 
        { ISD::ADD, ISD::SUB, ISD::MUL, ISD::UDIV, ISD::UREM, 
          ISD::AND, ISD::OR, ISD::XOR, ISD::SETCC };
    for (auto op : promoteSDs)
    {
        setOperationAction(op, MVT::i1, LegalizeAction::Promote);
    }

    setBooleanContents(BooleanContent::ZeroOrOneBooleanContent);
}

SDValue NNPUTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const
{
    switch (Op.getOpcode())
    {
    case ISD::GlobalAddress:
        return lowerGlobalAddress(Op, DAG);

    default: 
        llvm_unreachable("unhandled op code in lower operation");
        return SDValue();
    }
}

const char * NNPUTargetLowering::getTargetNodeName(unsigned Opcode) const
{
    switch (Opcode)
    {
    case NNPUISD::Ret:
        return "NNPUISD::Ret";

    default:
        return nullptr;
    }
}

#include "NNPUGenCallingConv.inc"

SDValue
    NNPUTargetLowering::LowerFormalArguments(
                            SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                            const SmallVectorImpl<ISD::InputArg> &Ins,
                            const SDLoc &dl, SelectionDAG &DAG,
                            SmallVectorImpl<SDValue> &InVals) const
{
    return Chain;
}

SDValue 
    NNPUTargetLowering::LowerReturn(
                            SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                            const SmallVectorImpl<ISD::OutputArg> &Outs,
                            const SmallVectorImpl<SDValue> &OutVals,
                            const SDLoc &dl, SelectionDAG &DAG) const
{
    assert(Outs.size() == 0 && "NNPU has no real return support");
    return DAG.getNode(NNPUISD::Ret, dl, MVT::Other, Chain);
}

SDValue NNPUTargetLowering::lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const
{
    SDLoc DL(Op);
    EVT Ty = Op.getValueType();
    GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
    const GlobalValue *GV = N->getGlobal();

    SDValue addr = DAG.getTargetGlobalAddress(GV, DL, Ty, 0, NNPUISD::MO_ABS_ALL);
    SDValue zero = DAG.getRegister(NNPU::Zero, MVT::i32);// DAG.getTargetConstant(0, DL, Ty);
    return DAG.getNode(ISD::ADD, DL, Ty, zero, addr);
}

}  // end namespace llvm