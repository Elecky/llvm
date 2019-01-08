include "NNPUInstrFormats.td"

// binary ALU instrs
def AddU: FRR<add, "AddU">;
def SubU: FRR<sub, "SubU">;
def MulU: FRR<mul, "MulU">;
def DivU: FRR<udiv, "DivU">;
def ModU: FRR<urem, "ModU">;
def SLTU: FSetRR<setult, "SLTU">;
def SEQ: FSetRR<seteq, "SEQ">;
def XOR: FRR<xor, "XOR">;
def And: FRR<and, "And">;
def Or: FRR<or, "Or">;

// unary ALU instrs
def AddIU: FRI<add, "AddIU">;
def MulIU: FRI<mul, "MulIU">;
def DivIU: FRI<udiv, "DivIU">;
def ModIU: FRI<urem, "ModIU">;
def SLTIU: FSetRI<setult, "SLTIU">;
def SEQI: FSetRI<seteq, "SEQI">;
def XORI: FRI<xor, "XORI">;
def AndI: FRI<and, "AndI">;
def OrI: FRI<or, "OrI">;

// some user-defined SDNodes.
def NNPURet : SDNode<"NNPUISD::Ret", SDTNone,
                     [SDNPHasChain, SDNPOptInGlue]>;

// immediates.
def : Pat<(i32 imm:$val),
          (AddIU Zero, imm:$val)>;

// def : Pat<(NNPUMOAbsAll tglobaladdr:$in), 
//           (AddIU Zero, tglobaladdr:$in)>;
def : Pat<(i32 (sext i1:$val)),
          (AddIU $val, -1)>;

// sign extend
def : Pat<(i32 (select i32:$cond, -1, 0)),
          (AddIU (XORI $cond, 1), -1)>;

// relation operator patterns

// not equal: a != b -> (a == b) ^ 1
def : Pat<(i32 (setne i32:$Rs, i32:$Rt)),
          (XORI (SEQ $Rs, $Rt), 1)>;
def : Pat<(i32 (setne i32:$Rs, imm:$val)),
          (XORI (SEQ $Rs, $val), 1)>;

// greater than: a > b -> b < a
def : Pat<(i32 (setugt i32:$Rs, i32:$Rt)),
          (SLTU $Rt, $Rs)>;

// less than or equal: a <= b -> (b < a) ^ 1
def : Pat<(i32 (setule i32:$Rs, i32:$Rt)),
          (XORI (SLTU $Rt, $Rs), 1)>;

// greater than or equal: a >= b -> (a < b) ^ 1
def : Pat<(i32 (setuge i32:$Rs, i32:$Rt)), 
          (XORI (SLTU $Rs, $Rt), 1)>;
def : Pat<(i32 (setuge i32:$Rs, imm:$val)), 
          (XORI (SLTIU $Rs, imm:$val), 1)>;

// def : Pat<(), 
//           ()>;

// load and store
def MEMri : Operand<iPTR> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops ptr_rc, i32imm);  
  // ptr_rc is resolved dynamically via a callback to TargetInstrInfo.
}

// SelectADDRri method is implemented in NNPU's SelectionDAGISel derivate class
def ADDRri : ComplexPattern<iPTR, 2, "SelectADDRri", [add, frameindex], []>;

def Load : NNPUInst<(outs Int32Regs:$Rd), (ins MEMri:$addr),
                    "Load $Rd, $addr",
                    [(set i32:$Rd, (load ADDRri:$addr))]>
{
    let mayLoad = 1;
}

def Store : NNPUInst<(outs), (ins MEMri:$addr, Int32Regs:$Rt),
                     "Store $Rt, $addr",
                     [(store i32:$Rt, ADDRri:$addr)]>
{
    let mayStore = 1;
}

// store zero
def : Pat<(store (i32 0), ADDRri:$addr), 
          (Store ADDRri:$addr, Zero)>;

// jump and branch
def brtarget : Operand<OtherVT>;

def Jump : NNPUInst<(outs), (ins brtarget:$target),
                    "Jump $target",
                    [(br bb:$target)]>
{
    let isBranch = 1;
    let isTerminator = 1;
    // let isCodeGenOnly = 1;
}

def BNEZ : NNPUInst<(outs), (ins Int32Regs:$Rs, brtarget:$target),
                   "BNEZ $Rs, $target",
                   [(brcond (setne i32:$Rs, 0), bb:$target)]>
{
    let isBranch = 1;
    let isTerminator = 1;
    // let isCodeGenOnly = 1;
}

def BEZ : NNPUInst<(outs), (ins Int32Regs:$Rs, brtarget:$target),
                   "BEZ $Rs, $target",
                   [(brcond (seteq i32:$Rs, 0), bb:$target)]>
{
    let isBranch = 1;
    let isTerminator = 1;
    // let isCodeGenOnly = 1;
}

// patterns for branch instructions.
def : Pat<(brcond (xor i32:$cond, 1), bb:$target),
          (BEZ $cond, bb:$target)>;

def : Pat<(brcond i32:$cond, bb:$target),
          (BNEZ $cond, bb:$target)>;

def RetRA: NNPUInst<(outs), (ins),
                   "ret", [(NNPURet)]>
{
    let isReturn = 1;
    let isTerminator = 1;
    let isCodeGenOnly = 1;
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

include "NNPUTensorInstrInfo.td"