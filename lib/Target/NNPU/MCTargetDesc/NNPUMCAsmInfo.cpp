//===- NNPUMCAsmInfo.cpp - NNPU asm properties --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the NNPUMCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "NNPUMCAsmInfo.h"
#include "llvm/ADT/Triple.h"
#include "llvm/BinaryFormat/Dwarf.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCTargetOptions.h"

using namespace llvm;

void NNPUELFMCAsmInfo::anchor() 
{}

NNPUELFMCAsmInfo::NNPUELFMCAsmInfo(const Triple &TheTriple) {
    IsLittleEndian = true;

    Data32bitsDirective = "\t.word\t";
    // not 64-bit support
    // Data64bitsDirective = "\t.xword\t";
    ZeroDirective = "\t.space\t";
    CommentString = "#";
    // SupportsDebugInformation = true;

    // SunStyleELFSectionSwitchSyntax = true;
    // UsesELFSectionDirectiveForBSS = true;

    UseIntegratedAssembler = false;
}