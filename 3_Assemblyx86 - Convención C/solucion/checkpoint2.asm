extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp, rsp

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp


	call restar_c
	mov rdi, rax
	mov rsi, rdx
	call sumar_c
	mov rdi, rax
	mov rsi, rcx
	call restar_c

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp+0x18]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp

	;sub rdi, rsi
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rax, r8
	sub rax, r9
	add rax, [rbp + 0x10]
	sub rax, [rbp + 0x18]

	;epilogo
	pop rbp
	ret

; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	push rbp
	mov rbp, rsp

	; xorpd xmm1, xmm1
	; cvtsi2sd xmm1, rsi 	;convertimos x1(double word integer) a float
	; cvtss2sd xmm0, xmm0
	; mulsd xmm1, xmm0 ;multiplicamos los dos float
	; cvttsd2si rdx, xmm1
	; mov [rdi], edx


	pxor xmm1, xmm1
	cvtsi2sd xmm1, rsi
	cvtss2sd xmm0, xmm0
	mulsd xmm1, xmm0
	cvttsd2si rsi, xmm1
	mov [rdi], esi

	pop rbp
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp + 0x10], f6[xmm5], x7[rbp + 0x18], f7[xmm6], x8[rbp + 0x20], f8[xmm7],
;	, x9[rbp + 0x28], f9[rbp + 0x30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; CVTSS2SD—Convert Scalar Single Precision Floating-Point Value to Scalar Double Precision Floating-Point Value
	; Convert one single precision floating-point value in xmm2/m32 to one double precision floating-point value in xmm1.
	CVTSS2SD xmm0, xmm0
	CVTSS2SD xmm1, xmm1
	CVTSS2SD xmm2, xmm2
	CVTSS2SD xmm3, xmm3
	CVTSS2SD xmm4, xmm4
	CVTSS2SD xmm5, xmm5
	CVTSS2SD xmm6, xmm6
	CVTSS2SD xmm7, xmm7
	
	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; MULSD—Multiply Scalar Double Precision Floating-Point Value

	MULSD xmm0, xmm1
	MULSD xmm0, xmm2
	MULSD xmm0, xmm3
	MULSD xmm0, xmm4
	MULSD xmm0, xmm5
	MULSD xmm0, xmm6
	MULSD xmm0, xmm7


	; Traigo f9 que está en la pila a xmm1, lo convierto en double y lo multiplico
	cvtss2sd xmm1, [rbp+0x30]
	mulsd xmm0, xmm1


	; convertimos los enteros en doubles y los multiplicamos por xmm0.

	cvtsi2sd xmm1, rsi
	cvtsi2sd xmm2, rdx
	cvtsi2sd xmm3, rcx
	cvtsi2sd xmm4, r8
	cvtsi2sd xmm5, r9

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5

	cvtsi2sd xmm1, [rbp + 0x10]
	cvtsi2sd xmm2, [rbp + 0x18]
	cvtsi2sd xmm3, [rbp + 0x20]
	cvtsi2sd xmm4, [rbp + 0x28]

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	
	movsd [rdi], xmm0

	; epilogo
	pop rbp
	ret


