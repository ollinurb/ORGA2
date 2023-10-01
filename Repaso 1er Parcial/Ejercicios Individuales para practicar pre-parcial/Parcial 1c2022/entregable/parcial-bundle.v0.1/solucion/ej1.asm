extern malloc
extern calloc
extern strClone

global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity[rdi])
strArrayNew:
push rbp
mov rbp, rsp


; STRUCT{
; uint8_t size    
; uint8_t capacity
; char** data
;}

;necesitamos que cada dato este alineado a su tamaño, entonces vamos a tener al size en la pos 0x0, a capacity en 0x1, y a el puntero
;debemos agregar padding entre 0x2 y 0x7
; data en la posicion 0x8.
; en total el str_array_t tiene que ocupar 16 bytes y devolvemos el puntero al comienzo.
; pedimos Malloc para 0x10
; data es un puntero a punteros. apunta a un array de punteros. lo tenemos que crear vacio (porque todavia no hay nada)

;por un lado quiero reservar 16 bytes de memoria para guardar el array.
xor r13, r13
mov r13b, dil ;cl tiene capacity (copia) en tamaño byte (rdi->dil)
xor rsi, rsi
mov rsi, 8
call calloc ;llamamos a malloc con el tamaño para capacity cantidad de punteros
;rax reservó memoria para capacity punteros.
xor r12, r12
mov r12, rax
;rsi tiene el puntero a punteros que corresponde a data.

xor rdi, rdi
mov rdi, 16 ;voy a pasarle 16 bytes a malloc que es el tamaño del struct.
call malloc
;ahora en RAX tengo la dirección strArray_t* que voy a devolver.
mov BYTE [rax], 0 ;en el byte 1 ponemos el 0 de size (es una nueva estructura, no hay datos)
mov BYTE [rax + 1], r13b ;en el byte 2 ponemos el valor que corresponde a la capacidad de la estructura.
mov [rax + 8], r12 ;en el byte 8 ponemos el puntero a data.

;epilogo
pop rbp
ret

; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
push rbp
mov rbp, rsp

xor rax, rax
mov al, BYTE [rdi]

pop rbp
ret


; void  strArrayAddLast(str_array_t* a[rdi], char* data [rsi])
strArrayAddLast:
push rbp
mov rbp, rsp
push r12
push r13
push rbx

xor rbx, rbx
xor r13, r13

mov bl, BYTE [rdi] ;bl tiene size (rbx)
mov r13b, BYTE [rdi + 1] ;r13b tiene capacity

cmp bl, r13b ;si size==capacity, no tenemos mas capacidad
jz .noCapacity

shl rbx, 3 ;multiplicamos la cantidad de arrays x 8 para llegar a la posicion donde va el puntero del nuevo str
;osea este es el offset que vamos a usar en el array de punteros.


;tenemos que copiar la str.
;backupeamos rdi para llamar a malloc. rsi no hace falta backupearlo porque no lo volvemos a usar despues de hacer la copia.

xor r12, r12
mov r12, rdi ;r12 tiene el struct
add BYTE [r12], 1 ;aumentamos size en 1. (el byte 0 es el size) porque estamos agregando un elemento
mov rdi, rsi ;para copiar la str, la ponemos en rdi para llamar al clonador.
call strClone ;me volteo r8, rcx, etc (PARA ESTO ESTA BUENO USAR NO VOLATILES, PERO HAY QUE PUSHEARLOS)
;rax ahora tiene el puntero de la copia

xor r9, r9
mov r9, [r12 + 8] ;r9 ahora apunta al array de punteros del struct
add r9, rbx ; lo movemos a la posicion que indica size*8 para encontrar el primer puntero libre.

mov [r9], rax ;movemos la copia del string a la posicion libre

.noCapacity:
pop rbx
pop r13
pop r12
pop rbp
ret

; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
strArraySwap:
push rbp
mov rbp, rsp

pop rbp
ret

; void  strArrayDelete(str_array_t* a)
strArrayDelete:
push rbp
mov rbp, rsp

pop rbp
ret