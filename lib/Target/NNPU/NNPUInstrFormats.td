// the base instr class
class NNPUInstBase<dag outs, dag ins, string asmstr, 
                   list<dag> pattern>: Instruction
{
  let Namespace = "NNPU";

  let OutOperandList = outs;
  let InOperandList  = ins;

  let AsmString   = asmstr;
  let Pattern     = pattern;
  // let Itinerary   = itin;
}

class NNPUInst<dag outs, dag ins, string asmstr, list<dag> pattern>: 
    NNPUInstBase<outs, ins, asmstr, pattern>
{}

// ALU register-register instrs
class FRR<SDNode OpNode, string OpStr>:
    NNPUInst<(outs Int32Regs:$Rd), (ins Int32Regs:$Rs, Int32Regs:$Rt),
             !strconcat(OpStr, " $Rd, $Rs, $Rt"),
             [(set i32:$Rd, (OpNode i32:$Rs, i32:$Rt))]>
{}

class FSetRR<PatFrag OpFrag, string OpStr>:
    NNPUInst<(outs Int32Regs:$Rd), (ins Int32Regs:$Rs, Int32Regs:$Rt),
             !strconcat(OpStr, " $Rd, $Rs, $Rt"),
             [(set i32:$Rd, (OpFrag i32:$Rs, i32:$Rt))]>
{}

class FRI<SDNode OpNode, string OpStr>:
    NNPUInst<(outs Int32Regs:$Rd), (ins Int32Regs:$Rs, i32imm:$imm),
             !strconcat(OpStr, " $Rd, $Rs, $imm"),
             [(set i32:$Rd, (OpNode i32:$Rs, imm:$imm))]>
{}

class FSetRI<PatFrag OpFrag, string OpStr>:
    NNPUInst<(outs Int32Regs:$Rd), (ins Int32Regs:$Rs, i32imm:$imm),
             !strconcat(OpStr, " $Rd, $Rs, $imm"),
             [(set i32:$Rd, (OpFrag i32:$Rs, imm:$imm))]>
{}

class FIR<SDNode OpNode, string OpStr>:
    NNPUInst<(outs Int32Regs:$Rd), (ins i32imm:$imm, Int32Regs:$Rs),
             !strconcat(OpStr, " $Rd, $imm, $Rs"),
             [(set i32:$Rd, (OpNode imm:$imm, i32:$Rs))]>
{}