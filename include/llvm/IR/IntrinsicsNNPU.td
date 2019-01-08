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

def int_NNPU_demo : Intrinsic<[], [llvm_i32_ty, llvm_i32_ty],
                         [],
                         "llvm.NNPU.demo",
                         [SDNPHasChain, SDNPSideEffect]>;

}