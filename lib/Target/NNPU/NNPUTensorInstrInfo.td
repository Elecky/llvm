class NNPUTensorInst<dag ins, string asmstr, list<dag> pattern>: 
    NNPUInstBase<(outs), ins, asmstr, pattern>
{}

// def Demo : NNPUTensorInst<
//             (ins Int32Regs:$op1, Int32Regs:$op2),
//             "demo $op1, $op2",
//             [(int_NNPU_demo i32:$op1, i32:$op2)]>;
def DMALoad : NNPUTensorInst<
                (ins Int32Regs:$phyAddr, Int32Regs:$phyOffset, 
                     Int32Regs:$dramAddr, Int32Regs:$size),
                "DMALoad $phyAddr, $phyOffset, $dramAddr, $size",
                [(int_NNPU_DMALoad i32:$phyAddr, i32:$phyOffset,
                                   i32:$dramAddr, i32:$size)]>;

def DMAStore : NNPUTensorInst<
                (ins Int32Regs:$phyAddr, Int32Regs:$phyOffset, 
                     Int32Regs:$dramAddr, Int32Regs:$size),
                "DMAStore $phyAddr, $phyOffset, $dramAddr, $size",
                [(int_NNPU_DMAStore i32:$phyAddr, i32:$phyOffset,
                                   i32:$dramAddr, i32:$size)]>;

def ScratchpadLoad : NNPUTensorInst<
                (ins Int32Regs:$dramAddr, Int32Regs:$bufAddr, Int32Regs:$size),
                "ScratchpadLoad $dramAddr, $bufAddr, $size",
                [(int_NNPU_ScratchpadLoad i32:$dramAddr, i32:$bufAddr, i32:$size)]>;
                
def ScratchpadStore : NNPUTensorInst<
                (ins Int32Regs:$dramAddr, Int32Regs:$bufAddr, Int32Regs:$size),
                "ScratchpadStore $dramAddr, $bufAddr, $size",
                [(int_NNPU_ScratchpadStore i32:$dramAddr, i32:$bufAddr, i32:$size)]>;

class NNPUVctrBinary<string instrAsm, Intrinsic intrin> : 
                NNPUTensorInst<
                    (ins Int32Regs:$outAddr, Int32Regs:$in1Addr, Int32Regs:$in2Addr,
                         i32imm:$size, i32imm:$mode),
                    !strconcat(instrAsm, ".$size.$mode $outAddr, $in1Addr, $in2Addr"),
                    [(intrin i32:$outAddr, i32:$in1Addr, i32:$in2Addr,
                             imm:$size, imm:$mode)]
                    >;

def VAddV : NNPUVctrBinary<"VAddV", int_NNPU_VAddV>;
def VMulV : NNPUVctrBinary<"VMulV", int_NNPU_VMulV>;
def VGTMV : NNPUVctrBinary<"VGTMV", int_NNPU_VGTMV>;