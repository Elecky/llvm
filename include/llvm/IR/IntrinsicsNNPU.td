//===- IntrinsicsNNPU.td - Defines NNPU intrinsics ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the NNPU-specific intrinsics.
// NNPU uses intrinsics to handle tensor instructions.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "NNPU" in {

class int_NNPU_void<list<LLVMType> para_types, string name>:
            Intrinsic<
                [], 
                para_types,
                [IntrInaccessibleMemOnly],
                !strconcat("llvm.NNPU.", name),
                [SDNPHasChain, SDNPSideEffect]>;

class int_NNPU_void_3op<string name> :
            int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                          name>;

class int_NNPU_void_4op<string name> :
            int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                          name>;

class int_NNPU_void_5op<string name> :
            int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                          name>;

class int_NNPU_void_6op<string name> :
            int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, 
                           llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                          name>;

/* a class of NNPU intrin that returns int32 as result. which access scratchpad memory, but has no side-effect! */
class int_NNPU_int32<list<LLVMType> para_types, string name>:
        Intrinsic<[llvm_i32_ty], para_types, [IntrInaccessibleMemOnly], 
                    !strconcat("llvm.NNPU.", name), [SDNPHasChain]>;

}

def int_NNPU_DMALoad : int_NNPU_void_4op<"DMALoad">;
def int_NNPU_DMAStore : int_NNPU_void_4op<"DMAStore">;

def int_NNPU_DMABufLoad : int_NNPU_void_4op<"DMABufLoad">;
def int_NNPU_DMABufStore : int_NNPU_void_4op<"DMABufStore">;

def int_NNPU_ScratchpadLoad : int_NNPU_void_3op<"ScratchpadLoad">;
def int_NNPU_ScratchpadStore : int_NNPU_void_3op<"ScratchpadStore">;

// vector binary intrinsics.
def int_NNPU_VAddV : int_NNPU_void_5op<"VAddV">;
def int_NNPU_VSubV : int_NNPU_void_5op<"VSubV">;
def int_NNPU_VMulV : int_NNPU_void_5op<"VMulV">;
def int_NNPU_VGTMV : int_NNPU_void_5op<"VGTMV">;
def int_NNPU_VDivV : int_NNPU_void_5op<"VDivV">;

// vector unary intrinsics.
def int_NNPU_VExp : int_NNPU_void_4op<"VExp">;
def int_NNPU_VLog : int_NNPU_void_4op<"VLog">;

// vector-imm intrinsics
let ParamTypes = [llvm_i32_ty, llvm_i32_ty, llvm_double_ty, llvm_i32_ty, llvm_i32_ty] in
{
    def int_NNPU_VAddI : int_NNPU_void<[], "VAddI">;
    def int_NNPU_VSubI : int_NNPU_void<[], "VSubI">;
    def int_NNPU_VMulI : int_NNPU_void<[], "VMulI">;
    def int_NNPU_VDivI : int_NNPU_void<[], "VDivI">;
    def int_NNPU_VGTMI : int_NNPU_void<[], "VGTMI">;
    def int_NNPU_ISubV : int_NNPU_void<[], "ISubV">;
    def int_NNPU_IDivV : int_NNPU_void<[], "IDivV">;
}

// GEMM intrinsic
def int_NNPU_GEMM : int_NNPU_void<
        [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, 
         llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, 
         llvm_i1_ty, llvm_i1_ty], "GEMM">;


let ParamTypes = [llvm_i32_ty, llvm_i32_ty, llvm_double_ty, llvm_i32_ty, 
                    llvm_i32_ty, llvm_i32_ty] in 
{
    def int_NNPU_MAddI : int_NNPU_void<[], "MAddI">;
    def int_NNPU_MMulI : int_NNPU_void<[], "MMulI">;
    def int_NNPU_ISubM : int_NNPU_void<[], "ISubM">;
}

// ScratchpadCopy
def int_NNPU_ScratchpadCopy : int_NNPU_void_6op<"ScratchpadCopy">;
// CopyAccToBuffer
def int_NNPU_CopyAccToBuffer : int_NNPU_void_4op<"CopyAccToBuffer">;

// memset.
def int_NNPU_Memset : 
        int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_double_ty, llvm_i32_ty], 
        "Memset">;

// vector dor product.
def int_NNPU_VDotV : int_NNPU_void_5op<"VDotV">;

// vector reduce
def int_NNPU_VReduceSum : int_NNPU_void_4op<"VReduceSum">;
def int_NNPU_VReduceMax : int_NNPU_void_4op<"VReduceMax">;
def int_NNPU_VReduceMin : int_NNPU_void_4op<"VReduceMin">;

// matrix binary
let ParamTypes = [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty,
                    llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty] in 
{
    def int_NNPU_MAddM : int_NNPU_void<[], "MAddM">;
    def int_NNPU_MSubM : int_NNPU_void<[], "MSubM">;
    def int_NNPU_MMulM : int_NNPU_void<[], "MMulM">;
}

// matrix reduce.
let ParamTypes = [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty,
                  llvm_i32_ty, llvm_i1_ty, llvm_i1_ty] in 
{
    def int_NNPU_MReduceSumRow : int_NNPU_void<[], "MReduceSumRow">;
}

// matrix-vector.
let ParamTypes = [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty,
                  llvm_i32_ty, llvm_i32_ty, llvm_i32_ty] in 
{
    def int_NNPU_MAddV : int_NNPU_void<[], "MAddV">;
    def int_NNPU_MSubV : int_NNPU_void<[], "MSubV">;
    def int_NNPU_MMulV : int_NNPU_void<[], "MMulV">;
}

// matrix row dot
def int_NNPU_MRowDot : 
    int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty,
                   llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i1_ty, llvm_i1_ty],
                  "MRowDot">;

def int_NNPU_AccMemset :
    int_NNPU_void<[llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, 
                   llvm_double_ty, llvm_i32_ty],
                  "AccMemset">;

// vector-scalar 
def int_NNPU_VAddS : int_NNPU_void_5op<"VAddS">;
def int_NNPU_VSubS : int_NNPU_void_5op<"VSubS">;
def int_NNPU_VMulS : int_NNPU_void_5op<"VMulS">;
def int_NNPU_VDivS : int_NNPU_void_5op<"VDivS">;
def int_NNPU_VGTMS : int_NNPU_void_5op<"VGTMS">;
def int_NNPU_SSubV : int_NNPU_void_5op<"SSubV">;
def int_NNPU_SDivV : int_NNPU_void_5op<"SDivV">;

def int_NNPU_DependPush : int_NNPU_void<[llvm_i32_ty, llvm_i32_ty], "DependPush">;
def int_NNPU_DependPop : int_NNPU_void<[llvm_i32_ty, llvm_i32_ty], "DependPop">;

/* set a pipeline local register. arguments: PID, RegNo, Value */
def int_NNPU_SetPipelineReg : int_NNPU_void_3op<"SetPipelineReg">;
/* launch a micro-kernel on a pipeline. arguments: PID, KernelID, Loop0Ext, Loop1Ext */
def int_NNPU_LaunchMicroKernel : int_NNPU_void_4op<"LaunchMicroKernel">;

def int_NNPU_GetCoreIdx : 
        Intrinsic<
                [llvm_i32_ty], // return i32 type
                [],  // no parameter
                [IntrNoMem],
                !strconcat("llvm.NNPU.", "GetCoreIdx"),
                []>
{
    let TargetPrefix = "NNPU";
}

/* indicates loading a number from scratchpad buffer and converts to int32, then write it to register. */
def int_NNPU_MoveFromBuf :
        int_NNPU_int32<[llvm_i32_ty, llvm_i32_ty], "MoveFromBuf">;