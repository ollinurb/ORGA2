section .text
global _start

_start:
	MOV CL, [num1]
	MOV DL, 0x01
	ADD CL, DL

	;exit the program
	MOV EAX, 1
	XOR EBX, EBX
	INT 0x80

_data:
	num1 db 0xFF