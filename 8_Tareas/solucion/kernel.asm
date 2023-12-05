; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando

extern GDT_DESC
extern screen_draw_layout
extern IDT_DESC
extern idt_init
extern pic_reset
extern pic_enable
extern tss_init
extern sched_init
extern tasks_init

extern tasks_screen_draw

extern mmu_init_kernel_dir ; pusimos esto por diferencias con paginacion
extern mmu_init_task_dir

extern test_copy_page


; COMPLETAR - Definan correctamente estas constantes cuando las necesiten

%define GDT_IDX_CODE_0 1
%define GDT_IDX_DATA_0 3

%define TI_SEL 0
%define RPL_3 11b
%define RPL_0 00b


%define CS_RING_0_SEL (GDT_IDX_CODE_0 << 3) | (TI_SEL << 2) | RPL_0
%define DS_RING_0_SEL (GDT_IDX_DATA_0 << 3) | (TI_SEL << 2) | RPL_0

%define STACK_BASE 0x25000

%define GDT_IDX_TASK_INITIAL      11
%define GDT_IDX_TASK_IDLE         12


%define INITIAL_TASK_SEL (GDT_IDX_TASK_INITIAL << 3)
%define IDLE_TASK_SEL (GDT_IDX_TASK_IDLE << 3)

;seguimos la forma en la que se hicieron los defines de task sel


;directorios
%define KERNEL_PAGE_DIR 0x00025000

;tests
%define PAGE_FAULT_ONDEMAND_TEST 0x18000

;para controlar velocidad del clock
%define DIVISOR 0x3000

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

sched_initial_task_offset:     dd 0xFFFFFFFF
sched_initial_task_selector:   dw 0xFFFF
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

    mov eax, cr0
    
    or eax, 1

    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

    jmp CS_RING_0_SEL:modo_protegido


BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    mov ax, DS_RING_0_SEL
    
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; la convención de intel dice que si no usamos es, gs y fs: que los seteemos en 0.
    ; por qué no lo hacemos así? los vamos a usar en el futuro?

    ; COMPLETAR - Establecer el tope y la base de la pila

    mov ebp, STACK_BASE
    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO

    print_text_pm start_pm_msg, start_pm_len, 0x02, 5, 5

    ; COMPLETAR - Inicializar pantalla
    
    call screen_draw_layout

    ; Inicializar IDT
    call idt_init
    lidt [IDT_DESC]

    ; sobre la idt, al hacer idt info: originalmente nos mostraba que estabamos en la idt en las interrup syscalls

    ;Inicializar interrupciones / PIC
    call pic_reset
    call pic_enable

    ;inicializamos CR3

    call mmu_init_kernel_dir


    mov cr3, eax

    ;activamos paginación

    mov eax, cr0

    or eax, 0x80000000 ;activar bit CR0.PG

    mov cr0, eax

    ; agregar tss de tareas iniciales a gdt

    call tss_init
    
    call sched_init

    call tasks_init
    
    ; call tasks_screen_draw


    ;habria que speedear el clock aca.
    mov ax, DIVISOR
    out 0x40, al
    rol ax, 8        ; J: LO CAMBIÉ, originalmente era 8 pero se hacia lento para ver el programa
    out 0x40, al

    .d:
    mov ax, INITIAL_TASK_SEL  ; lo hicimos asi porque [INITIAL_TASK_SEL] no funcionaba
    ltr ax

    mov ax, IDLE_TASK_SEL
    mov word [sched_initial_task_selector], ax

    jmp far [sched_initial_task_offset]  ; saltamos aca porque offset tiene el selector y la basura para completar los 48bits

    ;activamos interrupciones (edit taller8: ya no necesitamos este sti porque activamos las interrupciones en el contexto de la tarea idle, a la que saltamos al final)

    ; sti

    ;aca podriamos testear interrupciones usando la isntruccion int
    ;.test_int_reloj:
    ;int 0x20 ;deberia ser la interrupcion de clock
    

    ; Ciclar infinitamente 
    .ciclo:
    int 88
    
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $



;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
