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

    // intrinsic handling
    // setOperationAction(ISD::INTRINSIC_VOID, MVT::Other, Custom);

    //setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1, Expand);
    //setOperationAction(ISD::SIGN_EXTEND, MVT::i1, Expand);
    setOperationAction(ISD::SELECT_CC, MVT::i32, Expand);
    //setOperationAction(ISD::SELECT, MVT::i32, Expand);
    setOperationAction(ISD::BR_CC, MVT::i32, Expand);

    // define promotes.
    // the SDOps which needs promote. 
    static const decltype(ISD::ADD) promoteSDs[] = 
        { ISD::ADD, ISD::SUB, ISD::MUL, ISD::UDIV, ISD::UREM, 
          ISD::AND, ISD::OR, ISD::XOR, ISD::SETCC };
    for (auto op : promoteSDs)
    {
        setOperationAction(op, MVT::i1, LegalizeAction::Promote);
    }

    // set boolean content.
    setBooleanContents(BooleanContent::ZeroOrOneBooleanContent);
}

SDValue NNPUTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const
{
    switch (Op.getOpcode())
    {
    case ISD::GlobalAddress:
        return lowerGlobalAddress(Op, DAG);

    case ISD::INTRINSIC_VOID:
        return lowerIntrinsic_Void(Op, DAG);

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
    MachineFunction &MF = DAG.getMachineFunction();
    // MachineRegisterInfo &RegInfo = MF.getRegInfo();
    // NNPUMachineFunctionInfo *FuncInfo = MF.getInfo<NNPUMachineFunctionInfo>();

    // Assign locations to all of the incoming arguments.
    SmallVector<CCValAssign, 16> ArgLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(), ArgLocs,
                    *DAG.getContext());
    CCInfo.AnalyzeFormalArguments(Ins, CC_NNPU);

    const unsigned StackOffset = 0;  // what's this??

    unsigned InIdx = 0;
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i, ++InIdx) {
        CCValAssign &VA = ArgLocs[i];

        if (Ins[InIdx].Flags.isSRet()) {
            llvm_unreachable("NNPUTargetLowering didn't handle SRet");
        }

        assert(VA.isMemLoc() && 
                ", NNPUTargetLowering didn't handle pass argument by register");
        
        unsigned Offset = VA.getLocMemOffset()+StackOffset;
        auto PtrVT = getPointerTy(DAG.getDataLayout());
        assert(!VA.needsCustom() && 
                ", NNPUTargetLowering didn't handle argument lowering that needs custom");
        
        int FI = MF.getFrameInfo().CreateFixedObject(4,
                                                    Offset,
                                                    true);
        SDValue FIPtr = DAG.getFrameIndex(FI, PtrVT);
        SDValue Load ;
        if (VA.getValVT() == MVT::i32) {
            Load = DAG.getLoad(VA.getValVT(), dl, Chain, FIPtr, MachinePointerInfo());
        } else {
            // We shouldn't see any other value types here.
            llvm_unreachable("Unexpected ValVT encountered in frame lowering.");
        }
        InVals.push_back(Load);
    }

    assert(!MF.getFunction().hasStructRetAttr() && 
            ", NNPU target has no struct support");
    assert(!isVarArg && ", NNPU target has no VarArg support");
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

    SDValue addr = DAG.getTargetGlobalAddress(GV, DL, Ty, 0, 0);
    SDValue zero = DAG.getRegister(NNPU::Zero, MVT::i32);// DAG.getTargetConstant(0, DL, Ty);
    return DAG.getNode(ISD::ADD, DL, Ty, zero, addr);
}

SDValue NNPUTargetLowering::lowerIntrinsic_Void(SDValue Op, SelectionDAG &DAG) const
{
    // SDValue inChain = Op.getOperand(0);
    unsigned IntNo = cast<ConstantSDNode>(Op.getOperand(1))->getZExtValue();
    SDLoc dl(Op);

    switch (IntNo) 
    {
    default: return SDValue();    // Don't custom lower most intrinsics.
    
    }
}

}  // end namespace llvm