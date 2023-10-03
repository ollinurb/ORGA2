%define monto_pago 0
%define aprobado_pago 1
%define pagador_pago 8
%define cobrador_pago 16

%define offset_next_elem 0
%define offset_last_elem 8

%define dato_lista 0
%define next_lista 8
%define prev_lista 16

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
xor rdx, rdx
mov rdx, [rdi + offset_last_elem] ;rdx es la guarda.
xor rcx, rcx
mov rcx, [rdi + offset_next_elem] ;iniciamos la iteracion en rcx
xor rax, rax ;en al acumulamos la respuesta

.cicloAp:
cmp rdx, rcx
jz .ultimoElementoAp
xor rbx, rbx
mov rbx, [rcx + dato_lista] ;en rbx tenemos el pago.
xor r8, r8
mov r8, [rbx + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .siguienteAp
xor r9, r9
mov r9b, BYTE [rbx + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jz .siguienteAp
add al, 1

.siguienteAp:
mov rcx, [rcx + next_lista]
jmp .cicloAp


.ultimoElementoAp:
xor rbx, rbx
mov rbx, [rcx + dato_lista] ;en rbx tenemos el pago.
xor r8, r8
mov r8, [rbx + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .finAp
xor r9, r9
mov r9b, BYTE [rbx + aprobado_pago]
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
xor rbx, rbx
mov rbx, [rcx + dato_lista] ;en rbx tenemos el pago.
xor r8, r8
mov r8, [rbx + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .siguienteDes
xor r9, r9
mov r9b, BYTE [rbx + aprobado_pago]
cmp r9b, 0 ;chequeamos si esta aprobado o no el pago.
jnz .siguienteDes
add al, 1

.siguienteDes:
mov rcx, [rcx + next_lista]
jmp .cicloDes


.ultimoElementoDes:
xor rbx, rbx
mov rbx, [rcx + dato_lista] ;en rbx tenemos el pago.
xor r8, r8
mov r8, [rbx + cobrador_pago] ;en r8 tenemos el cobrador.
cmp r8, rsi ; chequeamos si es el usuario que nos interesa.
jnz .finDes
xor r9, r9
mov r9b, BYTE [rbx + aprobado_pago]
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



pop rbp
ret