global temperature_asm

section .data
align 16
mask_alphas times 2 dq 0x0000FFFFFFFFFFFF
packed_3_div times 4 dd 0x00000003
pix1_template times 4 db 0x00, 0x00, 0x00, 0xFF
pix2_template times 4 db 0x00, 0x00, 0xFF, 0xFF
pix3_template_a times 4 db 0x00, 0x00, 0xFF, 0x00
pix3_template_b times 4 db 0x00, 0xFF, 0x00, 0xFF
pix4_template_a times 4 db 0x00, 0xFF, 0x00, 0x00
pix4_template_b times 4 db 0xFF, 0x00, 0x00, 0xFF
pix5_template_a times 4 db 0xFF, 0x00, 0x00, 0x00
pix5_template_b times 4 db 0x00, 0x00, 0x00, 0x00


pix5_template dd 0x000000FF
align 16
mask_bottom_xmm dq 0x0000000000000000, 0xFFFFFFFF00000000
align 16
mask_top_xmm dq 0x0000000000000000, 0x00000000FFFFFFFF
packed_1_doubles times 4 dd 1
packed_32_doubles times 4 dd 32
packed_96_doubles times 4 dd 96
packed_128_doubles times 4 dd 128
packed_160_doubles times 4 dd 160
packed_224_doubles times 4 dd 224



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

    xor r9, r9 ;r8 y r9 estan usados por src_row_size y dst_row_size, pero para estos ejercicios no los usamos. 
    ;prefiero usar estos antes de usas los registros no volatiles. los voy a usar para contar filas y columnas.

    ;sub rdx, 2 ;reduzco en 2 el width para poder usarlo como guarda. 

    .fila:

    xor r8, r8 ;el contador de columnas que vamos escribiendo.    
    .columna:
    cmp r8, rdx
    jz .sigFila

    movdqu xmm0, [rdi] ;traigo 4 pixeles.

    ;podemos procesar de 2 en 2 y despues juntar los 4 t.
    movq xmm2, xmm0 ;2 primeros pixeles en xmm2
    psrldq xmm0, 8 ;2 segundos pixeles en xmm0

    pmovzxbw xmm2, xmm2
    pmovzxbw xmm0, xmm0
    
    pand xmm0, [mask_alphas]
    pand xmm2, [mask_alphas]
    phaddsw xmm0, xmm0 ;sumo horizontal 2 veces para hacer R+G+B
    phaddsw xmm0, xmm0
    phaddsw xmm2, xmm2
    phaddsw xmm2, xmm2
    ;ahora podemos combinar xmm0 y xmm2.
    pand xmm0, [mask_bottom_xmm]
    pand xmm2, [mask_top_xmm]
    por xmm0, xmm2
    psrldq xmm0, 8
    ;ahora en xmm0 tenemos empaquetados los 4 valores.
    pmovzxwd xmm0, xmm0 ;expando para convertir a Single Precision FP Value (32 bits)
    cvtdq2ps xmm0, xmm0
    cvtdq2ps xmm1, [packed_3_div] ;quiero convertir los 3 empaquetados a Single FP.
    divps xmm0, xmm1
    cvttps2dq xmm0, xmm0 ;convertimos a int truncando
   
    ;tenemos los 4 T en xmm0, los registros xmm1 y xmm2 podemos reutilizarlos.

    ;FUNCION PARTIDA X<32
    movdqu xmm1, xmm0
    pslld xmm1, 2
    movdqa xmm2, [packed_128_doubles]
    paddd xmm1, xmm2
    packusdw xmm1, xmm1
    packuswb xmm1, xmm1
    pmovzxbd xmm1, xmm1
    pslld xmm1, 24
    psrld xmm1, 8
    movdqu xmm2, [pix1_template]
    por xmm1, xmm2
    ;XMM1 TIENE TODOS LOS PIXELES APLICANDO LA OPC 1 DE LA FUNCION

    ;FUNCION PARTIDA 32<X<96
    movdqu xmm2, xmm0
    movdqa xmm3, [packed_32_doubles]
    psubd xmm2, xmm3
    pslld xmm2, 2
    packusdw xmm2, xmm2
    packuswb xmm2, xmm2 ;los achico de double a byte
    pmovzxbd xmm2, xmm2 ;lo vuelvo a pasar a double p acomodar un pixel para cada t (c pixel es un double)
    pslld xmm2, 24
    psrld xmm2, 16
    movdqu xmm3, [pix2_template]
    por xmm2, xmm3
    ;XMM2 TIENE TODOS LOS PIXELES APLICANDO LA OPC 2 DE LA FUNCION

    ;funcion partida 96<x<160 < (t − 96) · 4, 255, 255 − (t − 96) · 4 >
    movdqu xmm3, xmm0
    movdqa xmm4, [packed_96_doubles]
    psubd xmm3, xmm4
    pslld xmm3, 2
    packusdw xmm3, xmm3
    packuswb xmm3, xmm3
    pmovzxbd xmm3, xmm3
    movdqu xmm4, [pix3_template_a]
    pslld xmm3, 24
    psrld xmm3, 8
    psubd xmm4, xmm3
    psrld xmm3, 16
    por xmm3, xmm4
    movdqu xmm4, [pix3_template_b]
    por xmm3, xmm4
    ;XMM3 TIENE TODOS LOS PIXELES APLICANDO LA OPC 3 DE LA FUNCION

    ;funcion partida 160<x<224
    movdqu xmm4, xmm0
    movdqa xmm5, [packed_160_doubles]
    psubd xmm4, xmm5
    pslld xmm4, 2
    packusdw xmm4, xmm4
    packuswb xmm4, xmm4
    pmovzxbd xmm4, xmm4
    movdqu xmm5, [pix4_template_a]
    pslld xmm3, 24
    psrld xmm4, 16
    psubd xmm5, xmm4
    movdqu xmm4, [pix4_template_b]
    por xmm4, xmm5
    ;XMM4 TIENE TODOS LOS PIXELES APLICANDO LA OPC 4 DE LA FUNCION

    ;funcion partida x>224
    movdqu xmm5, xmm0
    movdqa xmm6, [packed_224_doubles]
    psubd xmm5, xmm6
    pslld xmm5, 2
    packusdw xmm5, xmm5
    packuswb xmm5, xmm5
    pmovzxbd xmm5, xmm5
    movdqu xmm6, [pix5_template_a]
    psrld xmm5, 24
    psubd xmm6, xmm5
    movdqa xmm5, [pix5_template_b]
    por xmm5, xmm6
    ;XMM5 TIENE TODOS LOS PIXELES APLICANDO LA OPC 5 DE LA FUNCION

    ;ahora tenemos que armar las mascaras para cada t que tenemos en xmm0.
    ;necesitamos armar dobles guardas para pegarle justo donde esta el valor.
    ;usamos estas mascaras para despues ir y combinar desde xmm1 a xmm5 y sacar solo lo que nos interesa con un OR.


    ; si 31 es mayor a los T, guarda 1. hay que bajar de 32 a 31.
    movdqa xmm11, [packed_32_doubles]
    movdqa xmm12, [packed_1_doubles]
    psubd xmm11, xmm12
    movdqu xmm6, xmm11
    pcmpgtd xmm6, xmm0
    ;M1 en xmm6      T < 32

    ;si 96 es mayor a los T, y si t es mayor a 31
    ;usar 2 mascaras y combinarlas con un AND
    movdqa xmm7, xmm0
    pcmpgtd xmm7, xmm11 ;los t mayores a 31
    movdqa xmm8, [packed_96_doubles]
    pcmpgtd xmm8, xmm0
    pand xmm7, xmm8
    ;M2 en xmm7  32 <= X < 96

    ;si 160 es mayor a los T, y si t es mayor a 95
    movdqa xmm8, xmm0
    movdqa xmm11, [packed_96_doubles]
    psubd xmm11, xmm12 ;96 - 1 = 95
    pcmpgtd xmm8, xmm11 ;los t mayores a 95
    movdqa xmm9, [packed_160_doubles]
    pcmpgtd xmm9, xmm0
    pand xmm8, xmm9
    ;M3 en xmm8 96 <= X < 160

    ;si 224 es mayor a los T, y si t es mayor a 159
    movdqa xmm9, xmm0
    movdqa xmm11, [packed_160_doubles]
    psubd xmm11, xmm12
    pcmpgtd xmm9, xmm11
    movdqa xmm10, [packed_224_doubles]
    pcmpgtd xmm10, xmm0
    pand xmm9, xmm10
    ;M4 en xmm9 160 <= X < 224

    ;si los T son mayores a 223
    movdqa xmm10, xmm0
    movdqa xmm11, [packed_224_doubles]
    psubd xmm11, xmm12
    pcmpgtd xmm10, xmm11
    ;M5 en xmm10 X >= 224
    
    ;ahora comparamos xmm(i) con xmm(i+5) 1 <= i <= 5
    pand xmm1, xmm6
    pand xmm2, xmm7
    pand xmm3, xmm8
    pand xmm4, xmm9
    pand xmm5, xmm10

    por xmm1, xmm2
    por xmm1, xmm3
    por xmm1, xmm4
    por xmm1, xmm5

    movdqu [rsi], xmm1
    add rdi, 16
    add rsi, 16
    add r8, 4
    jmp .columna

    .sigFila:
    add r9, 1
    cmp r9, rcx
    jz .fin
    jmp .fila

    .fin:
    ;epilogo
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
