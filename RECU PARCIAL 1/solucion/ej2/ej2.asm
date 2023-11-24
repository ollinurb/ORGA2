global combinarImagenes_asm


section .data
only_blue_components times 4 db 0xFF, 0x00, 0x00, 0x00
only_red_components times 4 db 0x00, 0x00, 0xFF, 0x00
only_green_components times 4 db 0x00, 0xFF, 0x00, 0x00
all_ones times 16 db 0xFF
alphas  times 4 db 0x00, 0x00, 0x00, 0xFF
packed_128s_in_green_component times 4 db 0, 128, 0, 0

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;rdi = src1
;rsi = src2
;rdx = dst
;rcx = width
;r8 = height

combinarImagenes_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r10

    ;como voy a loopear? proceso de 2 pixeles a la vez. c pixel ocupa 4 bytes. me muevo de a 8 bytes. 

    xor r9, r9

    .fila:
    xor r10, r10 ;el contador de columnas que vamos escribiendo.    
    .columna:
    cmp r10, rcx
    jz .sigFila

    movdqu xmm0, [rdi] ;4 pixeles source1.
    movdqu xmm1, [rsi] ;4 pixeles source2.

    ;que hago con ellos?
    ;depende para cada pixel, apliquemos todo a todo y despues enmascaramos.

    ;el formato es BGRA.
    ;el parametro B de salida es scr1_B + scr2_R
    ;si enmascaro el resto de los pixeles puedo sumar los xmm.
    movdqu xmm2, [only_blue_components]
    movdqu xmm3, [only_red_components]

    pand xmm2, xmm0
    pand xmm3, xmm1

    psrld xmm3, 16
    ;que pasa con el overflow? hay que procesar de a 2. Pruebo sumando de a word ya que la siguiente componente esta en 0
    
    ;hay que saturar en 255.
    paddusb xmm2, xmm3 
    movdqu xmm5, xmm2 ;xmm5 tiene ahora el componente azul.

    ;el parametro R es la inversa, es una resta. scr2_B - scr1_R
    ; mismo procedimiento?
    movdqu xmm2, [only_blue_components]
    movdqu xmm3, [only_red_components]
    
    pand xmm2, xmm1
    pand xmm3, xmm0
    psrld xmm3, 16

    ;hay que saturar en 0.
    psubusb xmm2, xmm3 
    movdqu xmm6, xmm2 ;xmm6 tiene el componente rojo

    ;el componente verde depende de si scr1_G > scr2_G
    ;debemos calcular las dos opciones, y despues enmascarar en base a esto.

    ;CASO G1: scr1_G - scr2_G
    movdqu xmm7, [only_green_components]
    movdqu xmm8, [only_green_components]
    pand xmm7, xmm0
    pand xmm8, xmm1

    psubusb xmm7, xmm8 ;xmm7 tiene el componente verde si OPC1

    ;CASO G2: promedio(scr1_G,scr2_G)
    movdqu xmm8, [only_green_components]
    movdqu xmm9, [only_green_components]
    pand xmm8, xmm0
    pand xmm9, xmm1
    pavgb xmm8, xmm9 ;xmm8 tiene el componente verde si OPC2

    ;ahora debemos armar la mascara para ver si es OPC1 o OPC2.
    movdqu xmm9, [only_green_components]
    movdqu xmm10, [only_green_components]
    pand xmm9, xmm0
    pand xmm10, xmm1

    ;para poder usar pcmpgtb (que opera con signo) restamos 128 a los componentes para que funcione.

    movdqu xmm11, [packed_128s_in_green_component]
    psubb xmm9, xmm11
    psubb xmm10, xmm11

    pcmpgtb xmm9, xmm10 ;xmm9 tiene la mascara donde SCR1_G > SCR2_G

    movdqu xmm10, [only_green_components]
    pxor xmm10, xmm9 ;xmm10 tiene la mascara donde SRC_G <= SCR2_G

    pand xmm7, xmm9
    pand xmm8, xmm10

    por xmm7, xmm8 ;xmm7 tiene el componente verde

    ;ahora si shifteamos todo para ponerlo en la posicion final y le agregamos 255 en el alpha estamos.

    ;blue esta en la posicion correcta en xmm5
    ;red hay que shiftearlo 2 a izquierda
    pslld xmm6, 16
    ;green esta en posicion correcto
    por xmm5, xmm6
    por xmm5, xmm7
    
    movdqu xmm8, [alphas]
    por xmm5, xmm8

    ;sig iteracion
    movdqu [rdx], xmm5 ;escribimos 4 pixeles en salida
    add rdi, 16
    add rsi, 16
    add rdx, 16
    add r10, 4
    jmp .columna

    .sigFila:
    add r9, 1
    cmp r9, r8
    jz .fin
    jmp .fila

    .fin:
    ;epilogo
    pop r10
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
