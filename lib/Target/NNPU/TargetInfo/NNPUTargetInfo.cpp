//===-- SparcTargetInfo.cpp - Sparc Target Implementation -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "NNPU.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

Target& llvm::getTheNNPUTarget() {
  static Target TheNNPUTarget;
  return TheNNPUTarget;
}

extern "C" void LLVMInitializeNNPUTargetInfo() {
  RegisterTarget<Triple::NNPU, /*HasJIT=*/false> X(getTheNNPUTarget(), "NNPU",
                                                   "NNPU", "NNPU");
}
