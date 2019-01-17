class NNPUTensorInst<dag ins, string asmstr, list<dag> pattern>: 
    NNPUInstBase<(outs), ins, asmstr, pattern>
{}

// def Demo : NNPUTensorInst<
//             (ins Int32Regs:$op1, Int32Regs:$op2),
//             "demo $op1, $op2",
//             [(int_NNPU_demo i32:$op1, i32:$op2)]>;