extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a[rdi] b[rsi]
strCmp:

	ret

; char* strClone(char* a)
; // Genera una copia del string pasado por parámetro. El puntero pasado siempre es válido
; // aunque podría corresponderse a la cadena vacía.
; el string esta en rdi, habria que pedir memoria de la misma longitud del string a. ¿como llamamos a strLen?


strClone:
	push rbp
	mov rbp, rsp

	call strLen
	mov ebx, eax ; en ebx tenemos el string len.
	cmp ebx, 0
	jz end
	 ; ahora tendriamos la cantidad que queremos pedir de malloc. 
	; el unico parametro que recibe malloc es el size y devuelve el puntero. osea nos da la direccion donde vamos a escribir.
	; como son bytes el size es strLen.
	mov rsi, rdi ;voy a necesitar poner en rdi el valor del size. rsi tiene el string
	xor rdi, rdi 
	mov rdi, rax
	call malloc ;ahora en rax tendriamos el puntero donde vamos a ir copiando los datos de rsi.
	mov rdx, rax

	routine:
	mov [rdx], [rsi]
	inc rdx
	inc rsi
	dec ebx
	cmp ebx, 0
	jnz routine

	end:
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	ret

;// Escribe el string en el stream indicado a través de pFile. Si el string es vacío debe escribir "NULL"
; void strPrint(char* a, FILE* pFile)
strPrint:
	;registros: a[rdi] pfile[rsi]
	push rbp
	mov rbp, rsp
	;para llamar a fprntf hay que rotar los registros.
	mov rbx, rdi
	mov rdi, rsi
	mov rsi, rbx

	;solo queremos imprimir los caracteres validos, necesitamos loopear.
	cmp BYTE [rsi], 0
	jz fin3
	bucle2:
	call fprintf
	inc rsi
	cmp BYTE [rsi], 0
	jnz bucle2

	fin3:
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp

	xor rax, rax
	cmp byte [rdi], 0
	jz fin2

	bucle3:
	add eax, 1
	inc rdi
	cmp byte [rdi], 0
	jnz bucle3
	fin2:
	pop rbp

	ret