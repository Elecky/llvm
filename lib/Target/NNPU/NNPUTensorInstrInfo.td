class NNPUTensorInst<dag ins, string asmstr, list<dag> pattern>: 
    NNPUInstBase<(outs), ins, asmstr, pattern>
{}

def FP64Imm : ComplexPattern<f64, 1, "SelectFP64Imm", [fpimm]>;

def Switch : ComplexPattern<i1, 1, "SelectI1Imm", [imm]>;

// load and store
def BoolOp : Operand<i1> {
  let PrintMethod = "printBoolOperand";
  let MIOperandInfo = (ops i1imm);  
  // ptr_rc is resolved dynamically via a callback to TargetInstrInfo.
}

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

// vector binary insns.
class NNPUVctrBinary<string instrAsm, Intrinsic intrin> : 
                NNPUTensorInst<
                    (ins Int32Regs:$outAddr, Int32Regs:$in1Addr, Int32Regs:$in2Addr,
                         i32imm:$size, i32imm:$mode),
                    !strconcat(instrAsm, ".$size.$mode $outAddr, $in1Addr, $in2Addr"),
                    [(intrin i32:$outAddr, i32:$in1Addr, i32:$in2Addr,
                             imm:$size, imm:$mode)]
                    >;

def VAddV : NNPUVctrBinary<"VAddV", int_NNPU_VAddV>;
def VSubV : NNPUVctrBinary<"VSubV", int_NNPU_VSubV>;
def VMulV : NNPUVctrBinary<"VMulV", int_NNPU_VMulV>;
def VDivV : NNPUVctrBinary<"VDivV", int_NNPU_VDivV>;
def VGTMV : NNPUVctrBinary<"VGTMV", int_NNPU_VGTMV>;

// vector unary insns.
class NNPUVctrUnary<string instrAsm, Intrinsic intrin> : 
                NNPUTensorInst<
                    (ins Int32Regs:$outAddr, Int32Regs:$inAddr,
                         i32imm:$size, i32imm:$mode),
                    !strconcat(instrAsm, ".$size.$mode $outAddr, $inAddr"),
                    [(intrin i32:$outAddr, i32:$inAddr,
                             imm:$size, imm:$mode)]
                    >;

def VExp : NNPUVctrUnary<"VExp", int_NNPU_VExp>;
def VLog : NNPUVctrUnary<"VLog", int_NNPU_VLog>;

// vector-immediate insns.
class NNPUVctrImm<string instrAsm, Intrinsic intrin> : 
                NNPUTensorInst<
                    (ins Int32Regs:$outAddr, Int32Regs:$inAddr, f64imm:$immVal,
                         i32imm:$size, i32imm:$mode),
                    !strconcat(instrAsm, ".$size.$mode $outAddr, $inAddr, $immVal"),
                    [(intrin i32:$outAddr, i32:$inAddr, FP64Imm:$immVal,
                             imm:$size, imm:$mode)]
                    >;

def VAddI : NNPUVctrImm<"VAddI", int_NNPU_VAddI>;
def VSubI : NNPUVctrImm<"VSubI", int_NNPU_VSubI>;
def VMulI : NNPUVctrImm<"VMulI", int_NNPU_VMulI>;
def VDivI : NNPUVctrImm<"VDivI", int_NNPU_VDivI>;
def VGTMI : NNPUVctrImm<"VGTMI", int_NNPU_VGTMI>;
def ISubV : NNPUVctrImm<"ISubV", int_NNPU_ISubV>;
def IDivV : NNPUVctrImm<"IDivV", int_NNPU_IDivV>;

// GEMM insn.
def GEMM : NNPUTensorInst<
               (ins i32imm:$nRow, i32imm:$factor, i32imm:$nCol,
                    Int32Regs:$outAddr, Int32Regs:$outStride,
                    Int32Regs:$in1Addr, Int32Regs:$in1Stride,
                    Int32Regs:$in2Addr, Int32Regs:$in2Stride,
                    i32imm:$mode, BoolOp:$toAcc, BoolOp:$doAcc),
               "GEMM.$nRow.$factor.$nCol.$mode.$toAcc.$doAcc $outAddr, $outStride, $in1Addr, $in1Stride, $in2Addr, $in2Stride",
               [(int_NNPU_GEMM 
                    imm:$nRow, imm:$factor, imm:$nCol,
                    i32:$outAddr, i32:$outStride,
                    i32:$in1Addr, i32:$in1Stride,
                    i32:$in2Addr, i32:$in2Stride,
                    imm:$mode, Switch:$toAcc, Switch:$doAcc)]>;

// matrix-immediate insns.
class NNPUMatImm<string instrAsm, Intrinsic intrin> : 
                NNPUTensorInst<
                    (ins Int32Regs:$outAddr, Int32Regs:$inAddr, f64imm:$immVal,
                         i32imm:$nRow, i32imm:$nCol, i32imm:$mode),
                    !strconcat(instrAsm, ".$nRow.$nCol.$mode $outAddr, $inAddr, $immVal"),
                    [(intrin i32:$outAddr, i32:$inAddr, FP64Imm:$immVal,
                             imm:$nRow, imm:$nCol, imm:$mode)]
                    >;

def MAddI : NNPUMatImm<"MAddI", int_NNPU_MAddI>;
def MMulI : NNPUMatImm<"MMulI", int_NNPU_MMulI>;
def ISubM : NNPUMatImm<"ISubM", int_NNPU_ISubM>;

// scratchpad copy
def ScratchpadCopy : 
          NNPUTensorInst<
               (ins Int32Regs:$dstAddr, Int32Regs:$dstStride,
                    Int32Regs:$srcAddr, Int32Regs:$srcStride,
                    i32imm:$unitBytes, Int32Regs:$nUnit),
               "ScratchpadCopy.$unitBytes $dstAddr, $dstStride, $srcAddr, $srcStride, $nUnit",
               [(int_NNPU_ScratchpadCopy 
                    i32:$dstAddr, i32:$dstStride,
                    i32:$srcAddr, i32:$srcStride,
                    imm:$unitBytes, i32:$nUnit)]>;

def CopyAccToBuffer :
          NNPUTensorInst<
               (ins Int32Regs:$dstAddr, Int32Regs:$srcAddr,
                    Int32Regs:$nUnit, i32imm:$mode),
               "CopyAccToBuffer.$mode $dstAddr, $srcAddr, $nUnit",
               [(int_NNPU_CopyAccToBuffer 
                    i32:$dstAddr, i32:$srcAddr,
                    i32:$nUnit, imm:$mode)]>;

def Memset :
          NNPUTensorInst<
               (ins Int32Regs:$addr, Int32Regs:$nUnit, Int32Regs:$stride,
                    f64imm:$val, i32imm:$mode),
               "Memset.$mode $addr, $nUnit, $stride, $val",
               [(int_NNPU_Memset 
                    i32:$addr, i32:$nUnit, i32:$stride,
                    FP64Imm:$val, imm:$mode)]
          >;

// vector dot product
def VDotV :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$in1Addr, Int32Regs:$in2Addr,
                    i32imm:$size, i32imm:$mode),
               "VDotV.$size.$mode $outAddr, $in1Addr, $in2Addr",
               [(int_NNPU_VDotV
                    i32:$outAddr, i32:$in1Addr, i32:$in2Addr,
                    imm:$size, imm:$mode)]
          >;

// vector reduce
class NNPUVctrReduce<string instrAsm, Intrinsic intrin> :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$inAddr,
                    i32imm:$size, i32imm:$mode),
               !strconcat(instrAsm, ".$size.$mode $outAddr, $inAddr"),
               [(intrin i32:$outAddr, i32:$inAddr, imm:$size, imm:$mode)]
          >;

def VReduceSum : NNPUVctrReduce<"VReduceSum", int_NNPU_VReduceSum>;
def VReduceMax : NNPUVctrReduce<"VReduceMax", int_NNPU_VReduceMax>;
def VReduceMin : NNPUVctrReduce<"VReduceMin", int_NNPU_VReduceMin>;

// matrix binary
class NNPUMatBinary<string instrAsm, Intrinsic intrin> :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$outStride,
                    Int32Regs:$in1Addr, Int32Regs:$in1Stride,
                    Int32Regs:$in2Addr, Int32Regs:$in2Stride,
                    i32imm:$nRow, i32imm:$nCol, i32imm:$mode),
               !strconcat(instrAsm, ".$nRow.$nCol.$mode $outAddr, $outStride, $in1Addr, $in1Stride, $in2Addr, $in2Stride"),
               [(intrin 
                    i32:$outAddr, i32:$outStride,
                    i32:$in1Addr, i32:$in1Stride,
                    i32:$in2Addr, i32:$in2Stride,
                    imm:$nRow, imm:$nCol, imm:$mode)]
          >;

def MAddM : NNPUMatBinary<"MAddM", int_NNPU_MAddM>;
def MSubM : NNPUMatBinary<"MSubM", int_NNPU_MSubM>;
def MMulM : NNPUMatBinary<"MMulM", int_NNPU_MMulM>;

// matrix reduce
def MReduceSumRow :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$inAddr, Int32Regs:$inStride,
                    i32imm:$nRow, i32imm:$nCol, i32imm:$mode,
                    BoolOp:$toAcc, BoolOp:$doAcc),
               "MReduceSumRow.$nRow.$nCol.$mode.$toAcc.$doAcc $outAddr, $inAddr, $inStride",
               [(int_NNPU_MReduceSumRow 
                    i32:$outAddr, i32:$inAddr, i32:$inStride,
                    imm:$nRow, imm:$nCol, imm:$mode,
                    Switch:$toAcc, Switch:$doAcc)]
          >;

// matrix vector
class NNPUMatVctr<string instrAsm, Intrinsic intrin> :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$outStride,
                    Int32Regs:$in1Addr, Int32Regs:$in1Stride, Int32Regs:$in2Addr,
                    i32imm:$nRow, i32imm:$nCol, i32imm:$mode),
               !strconcat(instrAsm, ".$nRow.$nCol.$mode $outAddr, $outStride, $in1Addr, $in1Stride, $in2Addr"),
               [(intrin
                    i32:$outAddr, i32:$outStride,
                    i32:$in1Addr, i32:$in1Stride, i32:$in2Addr,
                    imm:$nRow, imm:$nCol, imm:$mode)]
          >;

def MAddV : NNPUMatVctr<"MAddV", int_NNPU_MAddV>;
def MSubV : NNPUMatVctr<"MSubV", int_NNPU_MSubV>;
def MMulV : NNPUMatVctr<"MMulV", int_NNPU_MMulV>;

// matrix row dot
def MRowDot : 
          NNPUTensorInst<
               (ins Int32Regs:$outAddr,
                    Int32Regs:$in1Addr, Int32Regs:$in1Stride,
                    Int32Regs:$in2Addr, Int32Regs:$in2Stride,
                    i32imm:$nRow, i32imm:$nCol,
                    i32imm:$mode, BoolOp:$toAcc, BoolOp:$doAcc),
               "MRowDot.$nRow.$nCol.$mode.$toAcc.$doAcc $outAddr, $in1Addr, $in1Stride, $in2Addr, $in2Stride",
               [(int_NNPU_MRowDot 
                    i32:$outAddr,
                    i32:$in1Addr, i32:$in1Stride,
                    i32:$in2Addr, i32:$in2Stride,
                    imm:$nRow, imm:$nCol,
                    imm:$mode, Switch:$toAcc, Switch:$doAcc)]
          >;

def AccMemset :
          NNPUTensorInst<
               (ins Int32Regs:$addr, Int32Regs:$stride,
                    i32imm:$nRow, i32imm:$nCol,
                    f64imm:$val, i32imm:$mode),
               "AccMemset.$nRow.$nCol.$mode $addr, $stride, $val",
               [(int_NNPU_AccMemset
                    i32:$addr, i32:$stride,
                    imm:$nRow, imm:$nCol,
                    FP64Imm:$val, imm:$mode)]
          >;

// vector-scalar
class NNPUVctrSclr<string instrAsm, Intrinsic intrin> :
          NNPUTensorInst<
               (ins Int32Regs:$outAddr, Int32Regs:$in1Addr, Int32Regs:$in2Addr,
                    i32imm:$size, i32imm:$mode),
               !strconcat(instrAsm, ".$size.$mode $outAddr, $in1Addr, $in2Addr"),
               [(intrin i32:$outAddr, i32:$in1Addr, i32:$in2Addr,
                        imm:$size, imm:$mode)]
          >;

def VAddS : NNPUVctrSclr<"VAddS", int_NNPU_VAddS>;
def VSubS : NNPUVctrSclr<"VSubS", int_NNPU_VSubS>;
def VMulS : NNPUVctrSclr<"VMulS", int_NNPU_VMulS>;
def VDivS : NNPUVctrSclr<"VDivS", int_NNPU_VDivS>;
def VGTMS : NNPUVctrSclr<"VGTMS", int_NNPU_VGTMS>;
def SSubV : NNPUVctrSclr<"SSubV", int_NNPU_SSubV>;
def SDivV : NNPUVctrSclr<"SDivV", int_NNPU_SDivV>;