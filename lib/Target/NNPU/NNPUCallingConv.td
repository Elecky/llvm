def CC_NNPU : CallingConv<[
  // NNPU has no function call actually, 
  // this is only used to pass parameters to the 'main' function.
  CCAssignToStack<4, 4>
]>;

def RetCC_NNPU : CallingConv<[
  CCAssignToStack<4, 4>
]>;

// NNPU has no function call actually, 
// so we pretend that every register is preserved for both caller and callee.
def CSR : CalleeSavedRegs<(add)> {
  let OtherPreserved = (add (sequence "G%u", 4, 31));
}