OFFSET_A EQU 0x0
OFFSET_B EQU 0x10
OFFSET_C EQU 0x20
SIG_TERNA EQU 0x1C

section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
	;prologo
	push rbp
	mov rbp, rsp

	;cuerpo
	xor rdx, rdx
	xor rcx, rcx
	xor r9, r9

	pxor xmm0, xmm0
	movq xmm0, [rdi]
	pmovzxwd xmm0, xmm0
	; tomamos los valores correctos A B y C. Faltaria usar SIMD para calcular. 
	; como b y c son de 2 bytes, podemos meter 8 a la vez (IDEAL PORQUE VIENEN DE A 8)
	; lo hacemos de 4 en 4, luego expandidos, hacemos suma, y producto por 8 (ya tendriamos la extension)
	; esos resultados los comparamos 1 a 1 don los de C.

	mov bx, [rdi + OFFSET_A] 
	mov cx, [rdi + OFFSET_B]
	mov r9d, [rdi + OFFSET_C]

	result:
	;epilogo
	pop rbp
	ret


; 0000000000000000 0000000110100011 
; 0000000000000000 0000000011111001 
; 0000000000000000 0000000100010101 
; 0000000000000000 0000000100010001