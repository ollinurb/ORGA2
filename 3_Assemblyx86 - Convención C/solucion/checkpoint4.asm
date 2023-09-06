extern malloc
extern free
extern fprintf

section .data
null db "NULL"
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
	push rbx
	push r14
	xor rbx, rbx
	xor rax, rax
	xor r14, r14

	mov r14, rdi ;en r14 tengo el puntero al char original
	call strLen
	mov ebx, eax
	inc ebx ;ebx lo voy a usar como iterador, quiero que itere una vez mas para copiar el escape character
	cmp eax, 0
	jz end
	; ahora tendriamos la cantidad que queremos pedir de malloc. ¿nos falta un espacio mas para el escape character.
	; el unico parametro que recibe malloc es el size y devuelve el puntero. osea nos da la direccion donde vamos a escribir.
	; como son bytes el size es strLen.
	xor rdi, rdi
	mov edi, eax ;voy a necesitar poner en rdi el valor del size. guardo en rsi el puntero que estaba en rdi (el primer char).
	;inc eax ; lo incremento 1 para el escape character '\0'
	inc rdi ;eax tiene sizeof string original + 1
	call malloc ;ahora en rax tendriamos el puntero donde vamos a ir copiando los datos de rsi.
	mov rdx, rax ; la dir de memoria del puntero a copiar

	xor rcx, rcx

	routine:
	mov BYTE cl, [r14]
	mov [rdx], cl
	inc r14
	inc rdx
	dec ebx
	cmp ebx, 0
	jnz routine

	end:
	pop r14
	pop rbx
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
	push rbx
	push rbp

	;para llamar a fprntf hay que rotar los registros.
	mov rbx, rdi
	mov rdi, rsi
	mov rsi, rbx

	;solo queremos imprimir los caracteres validos, necesitamos loopear.
	cmp BYTE [rsi], 0
	jz esNull

	bucle2:
	call fprintf
	inc rsi
	cmp BYTE [rsi], 0
	jnz bucle2

	esNull:
	xor rsi, rsi
	mov ebp, null
	call fprintf
	;hay que printear NULL

	fin3:
	pop rbp
	pop rbx
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