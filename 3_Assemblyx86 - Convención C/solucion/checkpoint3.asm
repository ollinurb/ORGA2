

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
NODO_LENGTH	EQU	0x0030
LONGITUD_OFFSET	EQU	0x0018

PACKED_NODO_LENGTH	EQU	0x0001
PACKED_LONGITUD_OFFSET	EQU	0x0001

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	mov rcx, [rdi]
	xor eax, eax
	xor ebx, ebx
	loop:
	add ebx,  [rcx + LONGITUD_OFFSET]
	mov rcx, [rcx]
	cmp rcx, 0 ;puntero NULL == 0x0
	jnz loop
	add eax, ebx
	
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	ret

