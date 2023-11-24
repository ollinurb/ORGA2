; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0
%define str_proc_list_size 16
%define str_proc_node_size 32
%define str_list_first_offset 0
%define str_list_last_offset 8
%define str_node_next_offset 0
%define str_node_prev_offset 8
%define str_node_type_offset 16
%define str_node_hash_offset 24
section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat

string_proc_list_create_asm:
    push rbp
    mov rbp, rsp
    
    mov rdi, str_proc_list_size
    call malloc
    mov qword [rax + str_list_first_offset], 0
    mov qword [rax + str_list_last_offset], 0

    pop rbp
    ret

string_proc_node_create_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    ;backupear los 4 parametros en punteros no volatiles

    mov r12, rdi
    mov r13, rsi

    mov rdi, str_proc_node_size
    call malloc
    ;en rax tengo el nodo
    mov qword [rax + str_node_next_offset], 0
    mov qword [rax + str_node_prev_offset], 0
    mov byte [rax + str_node_type_offset], r12b
    mov [rax + str_node_hash_offset], r13

    pop r13
    pop r12
    pop rbp
    ret

string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    ;vamos a hacer un llamado a node_create, backupeemos los registros volatiles
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    mov r15, rcx

    mov rdi, rdx
    mov rsi, rcx
    call string_proc_node_create_asm
    ;en rax tengo el nuevo nodo.

    ;CASO 1: la lista esta vacia
    mov rdi, [r12 + str_list_first_offset]
    cmp rdi, 0
    jz .lista_vacia
    .lista_no_vacia:
    mov rsi, [r12 + str_list_last_offset]
    mov [rsi + str_node_next_offset], rax
    mov [rax + str_node_prev_offset], rsi
    mov [r12 + str_list_last_offset], rax
    jmp .fin
    .lista_vacia:
    mov [r12 + str_list_first_offset], rax
    mov [r12 + str_list_last_offset], rax

    .fin:

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

;char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
;
;	char* empty_hash = (char*)"";
;	char* new_hash = str_concat(empty_hash, hash);
;
;	string_proc_node* it = list->first;
;	while(it != NULL){
;		if(it->type == type){
;			//usamos el concat
;			char* hash_temp = new_hash;
;			new_hash = str_concat(hash_temp, it->hash);
;			free(hash_temp);
;			//aca pierdo memoria
;		}
;		it = it->next;
;	}
;	return new_hash;
;}


string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8
    mov qword [rsp], 0
    sub rsp, 8
    ;debemos mover los parametros a registros no volatiles porque vamos a llamar a str_concat
    mov r12, rdi ;list
    mov r13, rsi ;type

    mov rcx, rsp 
    add rcx, 8

    mov rdi, rcx ;ahi colocamos el puntero a char* vacio 
    mov rsi, rdx
    call str_concat ;en rax new_hash
    mov r15, rax
    ;consigamos el iterador
    mov r12, [r12 + str_list_first_offset]
    .ciclo:
    cmp r12, 0
    jz .fin
    cmp [r12 + str_node_type_offset], r13
    jz .otroTipo
    mov r14, r15 ;copiamos new_hash
    mov rdi, r14
    mov rsi, [r12 + str_node_hash_offset]
    call str_concat 
    mov r15, rax
    mov rdi, r14
    call free

    .otroTipo:
    mov r12, [r12 + str_node_next_offset]
    jmp .ciclo

    .fin:
    add rsp, 16
    push r15
    push r14
    push r13
    push r12
    push rbp
    ret
