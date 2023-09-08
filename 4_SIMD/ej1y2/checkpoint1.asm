
section .text

global invertirQW_asm

; void invertirQW_asm(uint64_t* p)

invertirQW_asm:
	;prologo
	push rbp
	mov rbp, rsp

	;cuerpo
	pxor xmm0, xmm0 
	pxor xmm1, xmm1
	movq xmm0, [rdi]
	pslldq xmm0, 8
	movq xmm1, [rdi + 0x08] ; ¿porque tengo que sumarle 8, es bytes no bits?
	por xmm0, xmm1

	movdqu [rdi], xmm0
	;epilogo
	pop rbp
	ret