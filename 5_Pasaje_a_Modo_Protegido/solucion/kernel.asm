; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando

extern GDT_DESC ; a confirmar si es así. es para el start en rm, utilizamos LDTR para cargar la GDT con esta variable (ubicada en gdt.c) 

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten

%define GDT_IDX_CODE_0 1
%define GDT_IDX_DATA_0 3

%define TI_SEL 0
%define RPL_3 11b
%define RPL_0 00b

%define CS_RING_0_SEL (GDT_IDX_CODE_0 << 3) | (TI_SEL << 2) | RPL_0
%define DS_RING_0_SEL (GDT_IDX_DATA_0 << 3) | (TI_SEL << 2) | RPL_0

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones

    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)

    print_text_rm start_rm_msg, start_rm_len, 0x02, 5, 5


    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)

    call A20_enable

    ; COMPLETAR - Cargar la GDT

    LGDT [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    ; COMPLETAR - Establecer el tope y la base de la pila

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO

    ; COMPLETAR - Inicializar pantalla
    
   
    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
