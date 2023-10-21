%define monto_pago 0
%define aprobado_pago 1
%define pagador_pago 8
%define cobrador_pago 16
%define tam_pago 24

%define offset_next_elem 0
%define offset_last_elem 8

%define dato_lista 0
%define next_lista 8
%define prev_lista 16

%define splitted_cant_aprobados 0
%define splitted_cant_rechazados 1
%define splitted_array_aprobados 8
%define splitted_array_desaprobados 16

section .data 
size_pago dw 8

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
;list_t* pList -> rdi
;char* usuario -> rsi
contar_pagos_aprobados_asm:
push rbp
mov rbp, rsp

;pList tiene el primer y el ultimo elemento de la lista. 
;Quiero iterar hasta llegar al ultimo elemento de la lista.

;no me hace falta chequear que sea el ultimo, como es una lista enlazada simplemente me aseguro que no apunte a NULL.
xor rdx, rdx
mov rdx, [rdi + offset_last_elem] ;rdx es la guarda.
xor rcx, rcx
mov rcx, [rdi + offset_next_elem] ;iniciamos la iteracion en rcx
xor rax, rax ;en al acumulamos la respuesta

.cicloAp:
cmp rdx, rcx
jz .ultimoElementoAp
xor r10, r10
mov r10, [rcx + dato_lista] ;en r10 tenemos el pago.
xor r8, r8
mov r8, [r10 + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .siguienteAp
xor r9, r9
mov r9b, BYTE [r10 + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jz .siguienteAp
add al, 1

.siguienteAp:
mov rcx, [rcx + next_lista]
jmp .cicloAp


.ultimoElementoAp:
xor r10, r10
mov r10, [rcx + dato_lista] ;en r10 tenemos el pago.
xor r8, r8
mov r8, [r10 + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .finAp
xor r9, r9
mov r9b, BYTE [r10 + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jz .finAp
add al, 1

.finAp:
pop rbp
ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
push rbp
mov rbp, rsp

;pList tiene el primer y el ultimo elemento de la lista. 
;Quiero iterar hasta llegar al ultimo elemento de la lista.
xor rdx, rdx
mov rdx, [rdi + offset_last_elem] ;rdx es la guarda.
xor rcx, rcx
mov rcx, [rdi + offset_next_elem] ;iniciamos la iteracion en rcx
xor rax, rax ;en al acumulamos la respuesta

.cicloDes:
cmp rdx, rcx
jz .ultimoElementoDes
xor r10, r10
mov r10, [rcx + dato_lista] ;en r10 tenemos el pago.
xor r8, r8
mov r8, [r10 + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .siguienteDes
xor r9, r9
mov r9b, BYTE [r10 + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jnz .siguienteDes
add al, 1

.siguienteDes:
mov rcx, [rcx + next_lista]
jmp .cicloDes


.ultimoElementoDes:
xor r10, r10
mov r10, [rcx + dato_lista] ;en r10 tenemos el pago.
xor r8, r8
mov r8, [r10 + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .finDes
xor r9, r9
mov r9b, BYTE [r10 + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jnz .finDes
add al, 1

.finDes:
pop rbp
ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
push rbp
mov rbp, rsp

push r12
push r13 ;los pusheo porque son no volatiles, los voy a usar para guardar mis parametros y no perderlos cuando llame a malloc.
push r14
push r15 ;los voy a usar para guardar en no volatiles la cantidad de pagos Aprob/Desap
push rbx    

sub rsp, 8 ;alineo la pila ;al hacer esto obteniamos segmentation fault al salir de la funcion.

mov r12, rdi ;r12 tiene la lista de pagos
mov r13, rsi ;r13 tiene el usuario

;ahora queremos armar el struct respuesta.
;typedef struct {
;  uint8_t cant_aprobados; 
;  uint8_t cant_rechazados;
;  pago_t** aprobados;
;  pago_t** rechazados;
; } pagoSplitted_t;
;podemos ver que el struct ocupa 24 bytes.
; cant_aprobados en offset 0
; cant_rechazados en offset 1
; aprobados en offset 8
; rechazados en offset 16

;queremos llamar a malloc con 16 para obtener 24 bytes de memoria reservada para el valor de retorno.
xor rdi, rdi
mov dil, 24
call malloc
xor rbx, rbx
mov rbx, rax ;rbx tiene el puntero al struct de respuesta. es no volatil.

mov rdi, r12
mov rsi, r13

call contar_pagos_aprobados_asm
xor r14, r14
mov r14b, BYTE al ;r14b tiene la cantidad de pagos aprobados
mov BYTE [rbx + splitted_cant_aprobados], r14b

mov rdi, r12
mov rsi, r13
call contar_pagos_rechazados_asm
xor r15, r15
mov r15b, BYTE al ;r15b tiene la cantidad de pagos rechazados
mov BYTE [rbx + splitted_cant_rechazados], r15b

;ademas vamos a llamar a malloc para los dos arrays de punteros que tienen las respuestas con los 
;tamaños que ya averiguamos. ¿cuanto ocupa cada pago? 24 bytes. 24 * cantidad es el tamaño 
;que queremos pedir para nuestros arrays de pagos.
; NO! solo quiero guardar punteros. 8 bytes * tamaño.

xor rax, rax
mov al, r14b
mul WORD [size_pago] ; [size_pago]*al === 8* cant pagos
xor rdi, rdi
mov rdi, rax
call malloc
mov QWORD [rbx + splitted_array_aprobados], rax

xor rax, rax
mov al, r15b
mul WORD [size_pago]
xor rdi, rdi
mov rdi, rax
call malloc
mov QWORD [rbx + splitted_array_desaprobados], rax

;ya tenemos los datos del struct respuesta. RECORDAR DEVOLVER EL PUNTERO RBX.

;ahora hay que llenar los arreglos aprobados y desaprobados con el contenido correspondiente. 
;rsi tiene el usuario.

;puedo reutilizar el viejo codigo, porque los registros son todos distintos.
xor rdi, rdi
mov rdi, r12
xor rsi, rsi
mov rsi, r13

;creo que no uso mas r12 y r13, los puedo reutilizar.
xor r12, r12
mov r12, [rbx + splitted_array_aprobados] ;el array de aprobados en r12
xor r13, r13
mov r13, [rbx + splitted_array_desaprobados] ;el array de desaprobados en r13

xor rdx, rdx
mov rdx, [rdi + offset_last_elem] ;rdx es la guarda.
xor rcx, rcx
mov rcx, [rdi + offset_next_elem] ;iniciamos la iteracion en rcx

.cicloAcum:
cmp rcx, 0
jz .finAcum

xor r10, r10
mov r10, [rcx + dato_lista] ;en r10 tenemos el pago.
xor r8, r8
mov r8, [r10 + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .siguienteAcum
xor r9, r9
mov r9b, BYTE [r10 + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jnz .pagoAprobado
;sino, pago desaprobado, agregar a la lista de desaprobado.
mov [r13], r10 ;agrego r10(el puntero al pago) a la posicion libre del array de desaprobados
add r13, 8 ;incremento el puntero de array de desaprobados en 8(lo que ocupa cada puntero)
jmp .siguienteAcum

.pagoAprobado:
mov [r12], r10
add r12, 8
jmp .siguienteAcum

.siguienteAcum:
mov rcx, [rcx + next_lista]
jmp .cicloAcum

.finAcum:
xor rax, rax
mov rax, rbx


add rsp, 8
pop rbx
pop r15
pop r14
pop r13
pop r12
pop rbp

;cuando sale de aca en el 1er test, produce un segmentation fault.

ret