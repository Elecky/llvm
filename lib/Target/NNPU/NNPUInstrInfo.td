include "NNPUInstrFormats.td"

// Li Instr
def Li : NNPUInst<(outs Int32Regs:$Rd), (ins i32imm:$imm),
                  "Li $Rd, $imm",
                  [(set i32:$Rd, imm:$imm)]>;

// binary ALU instrs
def AddU: FRR<add, "AddU">;
def SubU: FRR<sub, "SubU">;
def MulU: FRR<mul, "MulU">;
def DivU: FRR<udiv, "DivU">;
def ModU: FRR<urem, "ModU">;
def SLTU: FRR_Frag<setult, "SLTU">;
def SEQ: FRR_Frag<seteq, "SEQ">;
def XOR: FRR<xor, "XOR">;
def And: FRR<and, "And">;
def Or: FRR<or, "Or">;

// unary ALU instrs
def AddIU: FRI<add, "AddIU">;
def MulIU: FRI<mul, "MulIU">;
def DivIU: FRI<udiv, "DivIU">;
def ModIU: FRI<urem, "ModIU">;
def SLTIU: FRI_Frag<setult, "SLTIU">;
def SEQI: FRI_Frag<seteq, "SEQI">;
def XORI: FRI<xor, "XORI">;
def AndI: FRI<and, "AndI">;
def OrI: FRI<or, "OrI">;

def MEMri : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops ptr_rc, i32imm);  
  // ptr_rc is resolved dynamically via a callback to TargetInstrInfo.
}

// TODO: implement this SelectADDRri method, but at where?
def ADDRri : ComplexPattern<iPTR, 2, "SelectADDRri", [add, frameindex], []>;

// some user-defined SDNodes.
def NNPURet : SDNode<"NNPUISD::Ret", SDTNone,
                     [SDNPHasChain, SDNPOptInGlue]>;

def NNPUMOAbsAll : SDNode<"NNPUISD::MO_ABS_ALL", SDTIntUnaryOp>;

// immediates.
// def : Pat<(i32 imm:$val),
//           (AddIU Zero, imm:$val)>;

def : Pat<(NNPUMOAbsAll tglobaladdr:$in), 
          (AddIU Zero, tglobaladdr:$in)>;

def Load : NNPUInst<(outs Int32Regs:$Rd), (ins MEMri:$addr),
                    "Load $Rd, [$addr]",
                    [(set i32:$Rd, (load ADDRri:$addr))]>
{
    let mayLoad = 1;
}

def Store : NNPUInst<(outs), (ins MEMri:$addr, Int32Regs:$Rt),
                     "Store $Rt, [$addr]",
                     [(store i32:$Rt, ADDRri:$addr)]>
{
    let mayStore = 1;
}

// def Jump : NNPUInst<(outs), (ins i32imm:$target),
//                     "Jump $target",
//                     [(br bb:$target)]>
// {
//     let isBranch = 1;
// }

// def BNEZ : NNPUInst<(outs), (ins Int32Regs:$Rs, i32imm:$target),
//                    "BNEZ $Rs, $target",
//                    [(brcond i32:$Rs, bb:$target)]>
// {
//     let isBranch = 1;
// }

// def BEZ : NNPUInst<(outs), (ins Int32Regs:$Rs, i32imm:$target),
//                    "BEZ $Rs, $target",
//                    [(brcond (not i32:$Rs), bb:$target)]>
// {
//     let isBranch = 1;
// }

def RetRA: NNPUInst<(outs), (ins),
                   "ret", [(NNPURet)]>
{
    let isReturn = 1;
    let isTerminator = 1;
    let isCodeGenOnly = 1;
    let hasCtrlDep = 1;
    //let isPseudo = 1;
}

// def Ret: NNPUInst<(outs), (ins Int32Regs:$ra),
//                   "jr $ra",
//                   [(brind i32:$ra)]>
// {
//     let isReturn = 1;
//     let isCodeGenOnly = 1;
//     let hasCtrlDep = 1;
// }
/**/