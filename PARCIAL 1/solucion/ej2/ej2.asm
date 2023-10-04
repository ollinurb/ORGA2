global mezclarColores

section.data
align 16
red_pixels times 4 db 0xFF, 0x00, 0x00, 0x00
green_pixels times 4 db 0x00, 0xFF, 0x00, 0x00
blue_pixels times 4 db 0x00, 0x00, 0xFF, 0x00



;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
mezclarColores:
push rbp
mov rbp, rsp

;tengo que tomar de a 4 pixeles, tanto de X como de Y.

;Yo puedo enmascarar Xi para solo quedarme con Ri, para solo quedarme con Gi, 
; y para solo quedarme con Bi en 3 registros distintos.

;Luego hacer todas las comparaciones y armar la mascara final.

movdqu xmm0, [rdi] ;traigo 4 pixeles
movdqa xmm1, [red_pixels]
movdqa xmm2, [green_pixels]
movdqa xmm3, [blue_pixels]

por xmm1, xmm0
por xmm2, xmm0
por xmm3, xmm0

;habria que shiftear los registros para que c/componente quede al comienzo de la dword que ocupa cada pixel, asi al
;comparar tenemos todo en el mismo lugar.
;como es little-endian, red esta al comienzo. green hay que shiftearlo 8, y blue hay que shiftearlo 16.

psrld xmm2, 8
psrld xmm3, 16

;ahora tenemos que acumular para cada respuesta los compare.

pxor xmm4, xmm4
movdqu xmm4, xmm1
pcmpgtd xmm4, xmm2 ;en xmm4 tengo los R > G

pxor xmm5, xmm5
movdqu xmm5, xmm2
pcmpgtd xmm5, xmm3 ;en xmm5 tengo los G  > B

pand xmm4, xmm5 ;en xmm4 ahora tengo los pixeles a los que les tengo que aplicar la F1

pxor xmm6, xmm6
movdqu xmm6, xmm2
pcmpgtd xmm6, xmm1 ;en xmm6 tengo los R < G

pxor xmm7, xmm7
movdqu xmm7, xmm3
pcmpgtd xmm7, xmm2 ;en xmm7 tengo los G < B

pand xmm6, xmm7 ;en xmm6 ahora tengo los pixeles que les tengo que aplicar la F2

; ¿puedo combinar esta mascara para saber que pixeles van a F3? SI!
; les hago OR a ambas y luego niego ese registro.

pxor xmm8, xmm8
movdqu xmm8, xmm4
por xmm8, xmm6 ;en xmm8 tengo todos los pixeles que se les aplica F1 o F2.

;creo un registro con todos 1s
pcmpeqd xmm9, xmm9 ;xmm9 tiene todos 1s
pxor xmm8, xmm9 ;en xmm8 tengo los pixeles a los que se les aplica F2

;No llegué de tiempo, habria que meter todo esto en un ciclo que loopee de a 4 columnas y de a 1 fila cada vez
;que termina una columna. 

;para reordenar los pixeles no llegué a pensar una solución, pero podria usarse un shuffle.
;hacer las 3 opciones, y despues ir pisando con la mascara los pixeles que queremos. 

pop rbp
ret
