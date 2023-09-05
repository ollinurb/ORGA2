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
strClone:
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp
	xor rax, rax
	cmp BYTE [rdi], 0
	jz fin

	bucle:
	add eax, 1
	mov rdi, [rdi + 0x1]
	cmp BYTE rdi, 0
	jnz bucle
	fin:
	pop rbp

	ret