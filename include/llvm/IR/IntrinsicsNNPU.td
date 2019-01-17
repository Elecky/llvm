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
                [],
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

def int_NNPU_DMALoad : int_NNPU_void_4op<"DMALoad">;
def int_NNPU_DMAStore : int_NNPU_void_4op<"DMAStore">;

def int_NNPU_ScratchpadLoad : int_NNPU_void_3op<"ScratchpadLoad">;
def int_NNPU_ScratchpadStore : int_NNPU_void_3op<"ScratchpadStore">;

def int_NNPU_VAddV : int_NNPU_void_5op<"VAddV">;
def int_NNPU_VMulV : int_NNPU_void_5op<"VMulV">;
def int_NNPU_VGTMV : int_NNPU_void_5op<"VGTMV">;

}