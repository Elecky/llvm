//===-- NNPURegisterInfo.td - NNPU Register defs ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the NNPU register file
//===----------------------------------------------------------------------===//

class NNPUReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "NNPU";
}

// Registers are identified with 5-bit ID numbers.
// Ri - 32-bit integer registers
class Ri<bits<16> Enc, string n> : NNPUReg<Enc, n>;

def Zero : Ri<0, "Zero">, DwarfRegNum<[0]>;
def SP : Ri<1, "SP">, DwarfRegNum<[1]>;
def FP : Ri<2, "FP">, DwarfRegNum<[2]>;
// general registers, starts from G3
foreach i = {3-31} in {
    def G#i : Ri<#i, "G"#!cast<string>(#i)>, DwarfRegNum<[i]>;
}

// Register classes.
//

// 32-bit int register class
def Int32Regs : RegisterClass<"NNPU", [i32], 32,
                            (add Zero, SP, FP, 
                                 (sequence "G%u", 3, 31))
                           >;

def GP32Regs : RegisterClass<"NNPU", [i32], 32,
                            (add (sequence "G%u", 3, 31))
                           >;