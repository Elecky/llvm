; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32
define i32 @add_i32(i32 %x, i32 %y) {
; MIPS32-LABEL: add_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %z = add i32 %x, %y
  ret i32 %z
}

define signext i8 @add_i8_sext(i8 signext %a, i8 signext %b) {
; MIPS32-LABEL: add_i8_sext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $4, $5, $4
; MIPS32-NEXT:    sll $4, $4, 24
; MIPS32-NEXT:    sra $2, $4, 24
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i8 %b, %a
  ret i8 %add
}

define zeroext i8 @add_i8_zext(i8 zeroext %a, i8 zeroext %b) {
; MIPS32-LABEL: add_i8_zext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $4, $5, $4
; MIPS32-NEXT:    lui $5, 0
; MIPS32-NEXT:    ori $5, $5, 255
; MIPS32-NEXT:    and $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i8 %b, %a
  ret i8 %add
}

define i8 @add_i8_aext(i8 %a, i8 %b) {
; MIPS32-LABEL: add_i8_aext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i8 %b, %a
  ret i8 %add
}

define signext i16 @add_i16_sext(i16 signext %a, i16 signext %b) {
; MIPS32-LABEL: add_i16_sext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $4, $5, $4
; MIPS32-NEXT:    sll $4, $4, 16
; MIPS32-NEXT:    sra $2, $4, 16
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i16 %b, %a
  ret i16 %add
}

define zeroext i16 @add_i16_zext(i16 zeroext %a, i16 zeroext %b) {
; MIPS32-LABEL: add_i16_zext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $4, $5, $4
; MIPS32-NEXT:    lui $5, 0
; MIPS32-NEXT:    ori $5, $5, 65535
; MIPS32-NEXT:    and $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i16 %b, %a
  ret i16 %add
}

define i16 @add_i16_aext(i16 %a, i16 %b) {
; MIPS32-LABEL: add_i16_aext:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addu $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i16 %b, %a
  ret i16 %add
}

define i64 @add_i64(i64 %a, i64 %b) {
; MIPS32-LABEL: add_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    lui $1, 0
; MIPS32-NEXT:    ori $1, $1, 0
; MIPS32-NEXT:    addu $4, $6, $4
; MIPS32-NEXT:    lui $2, 0
; MIPS32-NEXT:    ori $2, $2, 1
; MIPS32-NEXT:    and $1, $1, $2
; MIPS32-NEXT:    addu $1, $4, $1
; MIPS32-NEXT:    sltu $2, $1, $6
; MIPS32-NEXT:    addu $4, $7, $5
; MIPS32-NEXT:    lui $5, 0
; MIPS32-NEXT:    ori $5, $5, 1
; MIPS32-NEXT:    and $2, $2, $5
; MIPS32-NEXT:    addu $3, $4, $2
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i64 %b, %a
  ret i64 %add
}

define i128 @add_i128(i128 %a, i128 %b) {
; MIPS32-LABEL: add_i128:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -8
; MIPS32-NEXT:    .cfi_def_cfa_offset 8
; MIPS32-NEXT:    addiu $1, $sp, 24
; MIPS32-NEXT:    lw $1, 0($1)
; MIPS32-NEXT:    addiu $2, $sp, 28
; MIPS32-NEXT:    lw $2, 0($2)
; MIPS32-NEXT:    addiu $3, $sp, 32
; MIPS32-NEXT:    lw $3, 0($3)
; MIPS32-NEXT:    addiu $8, $sp, 36
; MIPS32-NEXT:    lw $8, 0($8)
; MIPS32-NEXT:    lui $9, 0
; MIPS32-NEXT:    ori $9, $9, 0
; MIPS32-NEXT:    addu $4, $1, $4
; MIPS32-NEXT:    lui $10, 0
; MIPS32-NEXT:    ori $10, $10, 1
; MIPS32-NEXT:    and $9, $9, $10
; MIPS32-NEXT:    addu $4, $4, $9
; MIPS32-NEXT:    sltu $1, $4, $1
; MIPS32-NEXT:    addu $5, $2, $5
; MIPS32-NEXT:    lui $9, 0
; MIPS32-NEXT:    ori $9, $9, 1
; MIPS32-NEXT:    and $1, $1, $9
; MIPS32-NEXT:    addu $1, $5, $1
; MIPS32-NEXT:    sltu $2, $1, $2
; MIPS32-NEXT:    addu $5, $3, $6
; MIPS32-NEXT:    lui $6, 0
; MIPS32-NEXT:    ori $6, $6, 1
; MIPS32-NEXT:    and $2, $2, $6
; MIPS32-NEXT:    addu $2, $5, $2
; MIPS32-NEXT:    sltu $3, $2, $3
; MIPS32-NEXT:    addu $5, $8, $7
; MIPS32-NEXT:    lui $6, 0
; MIPS32-NEXT:    ori $6, $6, 1
; MIPS32-NEXT:    and $3, $3, $6
; MIPS32-NEXT:    addu $5, $5, $3
; MIPS32-NEXT:    sw $2, 4($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $2, $4
; MIPS32-NEXT:    move $3, $1
; MIPS32-NEXT:    lw $4, 4($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 8
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i128 %b, %a
  ret i128 %add
}
