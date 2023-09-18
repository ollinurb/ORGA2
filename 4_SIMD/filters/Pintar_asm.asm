%define pixel_negro 0xFF
%define pixel_blanco 0xFFFFFFFF


section .data
align 16
all_white_pixels times 4 db 0xFF, 0xFF, 0xFF, 0xFF
all_black_pixels times 4 db 0x00, 0x00, 0x00, 0xFF
black_white_pixels db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
white_black_pixels db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

pixel_b dd 0xFFFFFFFF
pixel_n dd 0xFF000000
pix dw 0xFFFF

global Pintar_asm

section .text
; unsigned char* src[rdi], unsigned char* dst[rsi], int width[rdx], int height[rcx], int src_row_size[r8], int dst_row_size[r9] 
Pintar_asm:	
	;prologo
	push rbp
	mov rbp, rsp
	;necesito un par de registros mas.
	push rbx
	push r14
	push r12
	push r13


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
	movdqa xmm3, [white_black_pixels]

	;ahora que tengo todos los bloques, deberia hacer un loop tradicional.
	xor rbx, rbx ; fila actual
	.filas: ;cada vez que termino una fila, vuelvo acá. deberiamos ir de la fila 0, hasta la fila height[rcx]
	;osea si fila actual es igual a height, terminé, me voy.
	cmp rbx, rcx
	jz .fin
	;ahora que estamos adentro del loop grande, tenemos que loopear columnas.
	;necesitamos un nuevo registro que para cada fila, arranque en 0 y empiece a contar.

	xor r14, r14 ;columna actual
	.columna:
	;habria que chequear que no nos salimos de la columna.
	cmp r14, rdx
	jz .finFila

	cmp rbx, 1 
	jle .4_black ;estamos en las dos primeras filas (todo negro)
	cmp rbx, r13 ; r13 es height - 2 // estamos en las dos ultimas filas (todo negro.)
	jge .4_black

	cmp r14, 0 ;r14 es columna actual
	jz .bbww

	cmp r14, r12 ; r12 es width - 4
	jz .wwbb

	;si no entra en ninguno de estos es todo blanco.
	.4_white:
	movdqu [rsi], xmm0
	jmp .siguienteBloque

	.4_black:
	movdqu [rsi], xmm1
	jmp .siguienteBloque

	.bbww:
	movdqu [rsi], xmm2
	jmp .siguienteBloque

	.wwbb:
	movdqu [rsi], xmm3
	jmp .siguienteBloque

	.siguienteBloque:
	add r14, 4
	add rsi, 16
	jmp .columna

	.finFila:
	add rbx, 1
	jmp .filas

	.fin:
	;epilogo
	pop r13
	pop r12
	pop r14
	pop rbx
	pop rbp
	ret
	


