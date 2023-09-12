; %define pixel_negro 0xFF
; %define pixel_blanco 0xFFFFFFFF

align 16
section .data
4_white_pixels times 4 db 0xFF, 0xFF, 0xFF, 0xFF
4_black_pixels times 4 db 0x00, 0x00, 0x00, 0xFF
; 2_black_2_white_pixels db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; 2_white_2_white_pixels db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
; pixel_b dd 0xFFFFFFFF
; pixel_n dd 0xFF000000
; pix dw 0xFFFF

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
	

	; me copio los witdh y height para ver que copio.
	xor rbx, rbx
	mov rbx, rdx ; copia de height
	xor rbp, rbp
	mov rbp, rdx ; copia de width

	pxor xmm0, xmm0
	pxor xmm1, xmm1
	pxor xmm2, xmm2
	pxor xmm3, xmm3

	; movdqa xmm0, [4_white_pixels]
	; movdqa xmm1, [4_black_pixels]
	; movdqa xmm2, [2_white_2_white_pixels]
	; movdqa xmm3, [2_black_2_white_pixels]

	
	cmp rbx, rdx
	jz .4_black
	cmp rbx, rdx - 1
	jz .4_black


	;podria predefinirme un pixel blanco y un pixel negro?
	;movdqa [rsi], xmm0 ;move aligned double quadword
	.4_black:


	;epilogo
	pop rbp
	pop rbx
	pop rbp
	ret
	


