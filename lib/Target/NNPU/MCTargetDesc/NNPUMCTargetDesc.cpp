//===-- NNPUMCTargetDesc.cpp - NNPU Target Descriptions -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides NNPU specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "NNPUMCTargetDesc.h"
#include "InstPrinter/NNPUInstPrinter.h"
#include "NNPUMCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "NNPUGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "NNPUGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "NNPUGenRegisterInfo.inc"

static MCAsmInfo *createNNPUMCAsmInfo(const MCRegisterInfo &MRI,
                                       const Triple &TT) {
    MCAsmInfo *MAI = new NNPUELFMCAsmInfo(TT);
    unsigned Reg = MRI.getDwarfRegNum(NNPU::SP, true);
    MCCFIInstruction Inst = MCCFIInstruction::createDefCfa(nullptr, Reg, 0);
    MAI->addInitialFrameState(Inst);
    return MAI;
}

static MCInstrInfo *createNNPUMCInstrInfo() {
    MCInstrInfo *X = new MCInstrInfo();
    InitNNPUMCInstrInfo(X);
    return X;
}

static MCRegisterInfo *createNNPUMCRegisterInfo(const Triple &TT) {
    MCRegisterInfo *X = new MCRegisterInfo();
    InitNNPUMCRegisterInfo(X, NNPU::G3);
    return X;
}

static MCSubtargetInfo *
createNNPUMCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
    return createNNPUMCSubtargetInfoImpl(TT, CPU, FS);
}

static MCInstPrinter *createNNPUMCInstPrinter(const Triple &T,
                                               unsigned SyntaxVariant,
                                               const MCAsmInfo &MAI,
                                               const MCInstrInfo &MII,
                                               const MCRegisterInfo &MRI) {
    return new NNPUInstPrinter(MAI, MII, MRI);
}

extern "C" void LLVMInitializeNNPUTargetMC() {
    // Register the MC asm info.
    RegisterMCAsmInfoFn X(getTheNNPUTarget(), createNNPUMCAsmInfo);

    for (Target *T :
          {&getTheNNPUTarget()}) {
        // Register the MC instruction info.
        TargetRegistry::RegisterMCInstrInfo(*T, createNNPUMCInstrInfo);

        // Register the MC register info.
        TargetRegistry::RegisterMCRegInfo(*T, createNNPUMCRegisterInfo);

        // Register the MC subtarget info.
        TargetRegistry::RegisterMCSubtargetInfo(*T, createNNPUMCSubtargetInfo);

        // Register the MC Code Emitter.
        // TargetRegistry::RegisterMCCodeEmitter(*T, createNNPUMCCodeEmitter);

        // Register the asm backend.
        // TargetRegistry::RegisterMCAsmBackend(*T, createNNPUAsmBackend);

        // Register the object target streamer.
        // TargetRegistry::RegisterObjectTargetStreamer(*T,
        //                                             createObjectTargetStreamer);

        // Register the asm streamer.
        // TargetRegistry::RegisterAsmTargetStreamer(*T, createTargetAsmStreamer);

        // Register the MCInstPrinter
        TargetRegistry::RegisterMCInstPrinter(*T, createNNPUMCInstPrinter);
    }
}
