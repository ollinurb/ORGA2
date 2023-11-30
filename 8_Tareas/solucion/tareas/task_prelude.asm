
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

extern task

BITS 32
global _start
_start:
	call task
	jmp $
