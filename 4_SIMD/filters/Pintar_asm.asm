%define pixel_negro 0xFF
%define pixel_blanco 0xFFFFFFFF

align 16
section .data
all_white_pixels times 4 db 0xFF, 0xFF, 0xFF, 0xFF
all_black_pixels times 4 db 0x00, 0x00, 0x00, 0xFF
black_white_pixels db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
white_black_pixels db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

pixel_b dd 0xFFFFFFFF
pixel_n dd 0xFF000000
pix dw 0xFFFF

global Pintar_asm

;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);



section .text
; unsigned char* src[rdi], unsigned char* dst[rsi], int width[rdx], int height[rcx], int src_row_size[r8], int dst_row_size[r9] 
Pintar_asm:	
	;prologo
	push rbp
	mov rbp, rsp
	;necesito un par de registros mas.
	push rbx
	push rbp
	push r12
	push r13
	

	xor rbx, rbx ; fila actual
	xor rbp, rbp ; columna actual

	xor r12, r12
	mov r12, rdx
	sub r12, 4 ; r12 tiene width - 4

	xor r13, r13
	mov r13, rcx
	sub r13, 2 ; r13 tiene height - 2
	pxor xmm0, xmm0
	pxor xmm1, xmm1
	pxor xmm2, xmm2
	pxor xmm3, xmm3

	movdqa xmm0, [all_white_pixels]
	movdqa xmm1, [all_black_pixels]
	movdqa xmm2, [black_white_pixels]
	movdqa xmm3, [black_white_pixels]

	
	; casos en los que pinto 4 negros. si el fila actual es 1, 2 , height original, o height original - 1.

	.kind_of_block:

	cmp rbx, 1
	jle .4_black
	cmp rbx, r13 ; r13 es rcx - 2 (height - 2)
	jge .4_black

	cmp rbp, 0
	jz .bbww

	cmp rbp, r12 ; r12 es rdx - 2
	jz .wwbb

	;si no entra en ninguno de estos es todo blanco.
	.4_white:
	movdqa [rsi], xmm0
	jmp .incrementador

	.incrementador: ;se fija si avanza el contador de filas, el contador de columnas, o si llegamos al final. 
	add rsi, 2
	cmp rbp, rdx
	jz .ultimaColumna 
	add rbp, 4 ;solo incremento el contador de columna actual, me mantengo en la misma fila.
	jmp .kind_of_block

	.ultimaColumna:
	cmp rbx, rcx
	jz .fin ;estoy en la ultima celda, listo
	;sino no, y tengo que resetear el contador de columnas, e incrementar en 1 el contador de filas.
	add rbx, 4
	xor rbp, rbp
	jmp .kind_of_block ;vuelve a la rutina.

	.4_black:
	movdqa [rsi], xmm1
	jmp .incrementador

	.bbww:
	movdqa [rsi], xmm2
	jmp .incrementador

	.wwbb:
	movdqa [rsi], xmm3
	jmp .incrementador

	.fin:
	;epilogo
	pop r13
	pop r12
	pop rbp
	pop rbx
	pop rbp
	ret
	


