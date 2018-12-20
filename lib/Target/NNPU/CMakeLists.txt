set(LLVM_TARGET_DEFINITIONS NNPU.td)

tablegen(LLVM MipsGenRegisterInfo.inc -gen-register-info)

add_public_tablegen_target(MipsCommonTableGen)

add_llvm_target(NNPUCodeGen
  NNPUTargetMachine.cpp
  )

add_subdirectory(TargetInfo)