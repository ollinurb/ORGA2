OFFSET_A EQU 0x0
OFFSET_B EQU 0x10
OFFSET_C EQU 0x20
SIG_TERNA EQU 0x1C
OFFFSET_PART EQU 0x08
OFFFSET_PART_C EQU 0xA0

section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
	;prologo
	push rbp
	mov rbp, rsp

	;cuerpo
	
	pxor xmm0, xmm0 ; A(0:3)
	pxor xmm1, xmm1 ; A(4:7)
	pxor xmm2, xmm2 ; B(0:3)
	pxor xmm3, xmm3 ; B(4:7)
	pxor xmm4, xmm4 ; C(0:3)
	pxor xmm5, xmm5 ; C(4:7)

	movq xmm0, [rdi + OFFSET_A]
	pmovzxwd xmm0, xmm0
	movq xmm1, [rdi + OFFSET_A + OFFFSET_PART]
	pmovzxwd xmm1, xmm1
	movq xmm2, [rdi + OFFSET_B]
	pmovzxwd xmm2, xmm2
	movq xmm3, [rdi + OFFSET_B + OFFFSET_PART]
	pmovzxwd xmm3, xmm3
	movdq xmm4, [rdi + OFFSET_C]
	movdq xmm5, [rdi + OFFSET_C + OFFFSET_PART_C]

	paddd xmm0, xmm2 ; A+B(0:3)
	paddd xmm1, xmm3 ; A+B(4:7)

	pslld xmm0, 3 ; 8 * A+B(0:3)
	pslld xmm1, 3 ; 8 * A+B(4:7)

	pcmpeqd xmm0, xmm4 ;si son iguales, deja todo en 1
	pcmpeqd xmm1, xmm5 ;idem

	; que hago con este dato? sumo todo? osea si es correcto, pcmpeqd == 0x FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 

	; MOVD/Q with 32/64 reg/mem destination:
	; Stores the low dword/qword of the source XMM register to 32/64-bit memory location or general-purpose register. 
	; Qword operation requires the use of REX.W=1, VEX.W=1, or EVEX.W=1.

	;tenemos que meter las cuatro qwords que estan en xmm0 y xmm1 en estos cuatro registros r64.
	xor rcx, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9

	movq rcx, xmm0
	; habria que shiftear la doublequadword a derecha 8 bytes.
	movq rdx, xmm0
	movq r8, xmm1
	; habria que shiftear la doublequadword a derecha 8 bytes.
	movq r9, xmm1


	; tomamos los valores correctos A B y C. Faltaria usar SIMD para calcular. 
	; como b y c son de 2 bytes, podemos meter 8 a la vez (IDEAL PORQUE VIENEN DE A 8)
	; lo hacemos de 4 en 4, luego expandidos, hacemos suma, y producto por 8 (ya tendriamos la extension)
	; esos resultados los comparamos 1 a 1 don los de C.
	; los 4 primeros uint16 ocupan 64bits/8bytes 
	; xmm0 -> AL; xmm1 -> AH; xmm2 -> BL; xmm3 -> BH; xmm4 -> CL; xmm5 -> CH

	result:
	;epilogo
	pop rbp
	ret


; 0000000000000000 0000000110100011 
; 0000000000000000 0000000011111001 
; 0000000000000000 0000000100010101 
; 0000000000000000 0000000100010001