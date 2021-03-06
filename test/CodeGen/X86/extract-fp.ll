; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2  | FileCheck %s

define float @ext_fadd_v4f32(<4 x float> %x) {
; CHECK-LABEL: ext_fadd_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-NEXT:    retq
  %bo = fadd <4 x float> %x, <float 1.0, float 2.0, float 3.0, float 42.0>
  %ext = extractelement <4 x float> %bo, i32 2
  ret float %ext
}

define float @ext_fsub_v4f32(<4 x float> %x) {
; CHECK-LABEL: ext_fsub_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = <u,2.0E+0,u,u>
; CHECK-NEXT:    subps %xmm0, %xmm1
; CHECK-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; CHECK-NEXT:    movaps %xmm1, %xmm0
; CHECK-NEXT:    retq
  %bo = fsub <4 x float> <float 1.0, float 2.0, float 3.0, float 42.0>, %x
  %ext = extractelement <4 x float> %bo, i32 1
  ret float %ext
}

define float @ext_fmul_v4f32(<4 x float> %x) {
; CHECK-LABEL: ext_fmul_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mulps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; CHECK-NEXT:    retq
  %bo = fmul <4 x float> %x, <float 1.0, float 2.0, float 3.0, float 42.0>
  %ext = extractelement <4 x float> %bo, i32 3
  ret float %ext
}

define float @ext_fdiv_v4f32(<4 x float> %x) {
; CHECK-LABEL: ext_fdiv_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    divps %xmm1, %xmm0
; CHECK-NEXT:    retq
  %bo = fdiv <4 x float> %x, <float 1.0, float 2.0, float 3.0, float 42.0>
  %ext = extractelement <4 x float> %bo, i32 0
  ret float %ext
}

define float @ext_fdiv_v4f32_constant_op0(<4 x float> %x) {
; CHECK-LABEL: ext_fdiv_v4f32_constant_op0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = <u,2.0E+0,u,u>
; CHECK-NEXT:    divps %xmm0, %xmm1
; CHECK-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; CHECK-NEXT:    movaps %xmm1, %xmm0
; CHECK-NEXT:    retq
  %bo = fdiv <4 x float> <float 1.0, float 2.0, float 3.0, float 42.0>, %x
  %ext = extractelement <4 x float> %bo, i32 1
  ret float %ext
}

define float @ext_frem_v4f32(<4 x float> %x) {
; CHECK-LABEL: ext_frem_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    jmp fmodf # TAILCALL
  %bo = frem <4 x float> %x, <float 1.0, float 2.0, float 3.0, float 42.0>
  %ext = extractelement <4 x float> %bo, i32 2
  ret float %ext
}

define float @ext_frem_v4f32_constant_op0(<4 x float> %x) {
; CHECK-LABEL: ext_frem_v4f32_constant_op0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps %xmm0, %xmm1
; CHECK-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1],xmm0[2,3]
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    jmp fmodf # TAILCALL
  %bo = frem <4 x float> <float 1.0, float 2.0, float 3.0, float 42.0>, %x
  %ext = extractelement <4 x float> %bo, i32 1
  ret float %ext
}

