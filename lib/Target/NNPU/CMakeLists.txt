set(LLVM_TARGET_DEFINITIONS NNPU.td)

tablegen(LLVM NNPUGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM NNPUGenCallingConv.inc -gen-callingconv)
tablegen(LLVM NNPUGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM NNPUGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM NNPUGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM NNPUGenSubtargetInfo.inc -gen-subtarget)

add_public_tablegen_target(NNPUCommonTableGen)

add_llvm_target(NNPUCodeGen
  NNPUAsmPrinter.cpp
  NNPUInstrInfo.cpp
  NNPUISelDAGToDAG.cpp
  NNPUISelLowering.cpp
  NNPUFrameLowering.cpp
  NNPUMachineFunctionInfo.cpp
  NNPURegisterInfo.cpp
  NNPUSubtarget.cpp
  NNPUTargetMachine.cpp
  NNPUMCInstLower.cpp
  NNPUTargetObjectFile.cpp
  )

add_subdirectory(InstPrinter)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)