global temperature_asm

section .data
align 16
mask_alphas times 2 dq 0x0000FFFFFFFFFFFF
packed_3_div times 4 dd 0x00000003
pix1_template dd 0x000000FF
pix2_template dd 0x0000FFFF
pix3_template dd 0x00FF00FF
pix4_template dd 0xFF0000FF
pix5_template dd 0x000000FF
align 16
mask_bottom_xmm dq 0x0000000000000000, 0xFFFFFFFF00000000
align 16
mask_top_xmm dq 0x0000000000000000, 0x00000000FFFFFFFF

section .text
;void temperature_asm(u80nsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

; src[rdi], dst[rsi], width[rdx], height[rcx]
temperature_asm:
    ;prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14

    ;como voy a loopear? proceso de 2 pixeles a la vez. c pixel ocupa 4 bytes. me muevo de a 8 bytes. 

    xor r8, r8 ;r8 y r9 estan usados por src_row_size y dst_row_size, pero para estos ejercicios no los usamos. 
    ;prefiero usar estos antes de usas los registros no volatiles. los voy a usar para contar filas y columnas.

    sub rdx, 2 ;reduzco en 2 el width para poder usarlo como guarda. 

    .fila:
    cmp r8, rdx
    jz .sigFila        

    xor r9, r9 ;el contador de columnas que vamos escribiendo.
    .columna:
    cmp r8, rcx
    jz .fin 
    movdqu xmm3, [rdi] ;traigo 4 pixeles.

    ;podemos procesar de 2 en 2 y despues juntar los 4 t.
    movq xmm4, xmm3 ;2 primeros pixeles en xmm4
    psrldq xmm3, 8 ;2 segundos pixeles en xmm3

    pmovzxbw xmm0, [rdi] ;tenemos 2 pixeles con 8 componentes extendidos a word. 
    ;habria que usar la mascara para limpiar el alpha. ¿como es la forma de la mascara?
    pmovzxbw xmm4, xmm4
    pmovzxbw xmm3, xmm3
    
    pand xmm0, [mask_alphas]
    pand xmm3, [mask_alphas]
    pand xmm4, [mask_alphas]
    phaddsw xmm0, xmm0 ;sumo horizontal 2 veces para hacer R+G+B
    phaddsw xmm0, xmm0
    phaddsw xmm3, xmm3
    phaddsw xmm3, xmm3
    phaddsw xmm4, xmm4
    phaddsw xmm4, xmm4
    ;ahora podemos combinar xmm3 y xmm4. desde aca prueba
    pand xmm3, [mask_bottom_xmm]
    pand xmm4, [mask_top_xmm]
    por xmm3, xmm4
    ;ahora en xmm3 tenemos empaquedados los 4 valores.
    pmovzxwd xmm0, xmm0 ;expando para convertir a Single Precision FP Value (32 bits)
    pmovzxwd xmm3, xmm3
    pmovzxwd xmm4, xmm4
    cvtdq2ps xmm0, xmm0
    cvtdq2ps xmm3, xmm3
    cvtdq2ps xmm4, xmm4
    cvtpi2ps xmm1, [packed_3_div] ;quiero convertir los 3 empaquetados a Single FP.
    divps xmm0, xmm1
    divps xmm3, xmm1
    divps xmm4, xmm1
    cvttps2dq xmm0, xmm0 ;convertimos a int truncando
    cvttps2dq xmm3, xmm3
    cvttps2dq xmm4, xmm4 
    ;hasta aca esta haciendo las cosas bien. habria que pedirle que lo haga por 2.

    xor r12, r12 
    movd r12d, xmm0 ;movemos t0
    pslldq xmm0, 4 ;movemos 4 bytes para tener el siguiente t.
    xor r13, r13
    movd r13d, xmm0

    .sigFila:

    ;pcmp xmm0, 

    .selectorT1:
    cmp r12d, 32
    jl .pix1
    cmp r12d, 96
    jl .pix2
    cmp r12d, 160
    jl .pix3
    cmp r12d, 224
    jl .pix4
    jmp .pix5

    .pix1:
    xor rax, rax
    mov rax, 4
    mul r12
    add al, 128
    pxor xmm2, xmm2
    ;mov byte xmm2, rax
    pslldq xmm2, 8

    .pix2:

    .pix3:

    .pix4:

    .pix5:

    pand xmm2, [pix1_template]

    ;ahora ya tenemos los valores de t0 y t1. Hay que tratarlos por separado. Podemos backupear y calcular 2 mas. Ya que vamos a escribir 4 pixeles.


    


    .fin:
    ;epilogo
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
