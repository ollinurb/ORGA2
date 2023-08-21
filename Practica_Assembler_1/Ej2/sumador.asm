section .text
global _start

_start:
	MOV EAX, num1
	MOV EBX, num2
	ADD EAX, EBX
	MOV EDX, 4
	int 0x80

section .data
 num1 db 0x0001
 num2 db 0x000a