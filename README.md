# Organización del Computador 2 - 2do Cuat 2023

## Material de cursada de Organización del Computador II

- Taller 1 (Clase introductoria de Assembler)
	- [Ejercicio 1](1_Intro_Y_Assembler/Ej1/holamundo.asm)
	- [Ejercicio 2](1_Intro_Y_Assembler/Ej2/sumador.asm)
- [Taller 2](2_POO_Memoria_Dinámica/)
	- [Lista enlazada](2_POO_Memoria_Dinámica/lista_enlazada.c)
	- [Vector](2_POO_Memoria_Dinámica/vector.c)
	- [Classify Chars](2_POO_Memoria_Dinámica/classify_chars.c)
- Taller 3
	- [Checkpoint 2](3_Assemblyx86_Convención_C/solucion/checkpoint2.asm)
	- [Checkpoint 3](3_Assemblyx86_Convención_C/solucion/checkpoint3.asm)
	- [Checkpoint 4](3_Assemblyx86_Convención_C/solucion/checkpoint4.asm)
- Taller 4
	- [Checkpoint 1](4_SIMD/ej1y2/checkpoint1.asm)
	- [Checkpoint 2](4_SIMD/ej1y2/checkpoint2.asm)
	- [Filtro Pintar](4_SIMD/filters/Pintar_asm.asm)
	- [Filtro Temperatura](4_SIMD/filters/temperature_asm.asm)


- Repaso Primer Parcial
	-[Ejercicio 1 - 1er Cuatrimestre 2022](<Repaso\ 1er\ Parcial/Ejercicios\ Individuales\ para\ practicar\ pre-parcial/Parcial\ 1c2022/entregable/parcial-bundle.v0.1/solucion/ej1.asm>)
## Como debuggear los filtros del taller 4

`gdb --args ./build/simd Pintar -i asm img/paisaje.bmp -o imagenes_salida/`

## Entorno de desarrollo

- Agregar Dockerfile al repo.
- Correr contenedor `docker start -t orga2`
	- orga2 es el nombre del contenedor, reemplazar por el nombre correcto.

## Instrucciones para ensamblar, linkear y ejecutar Assembler

- Ensamblar: `nasm -f elf64 -g -F DWARF ejemplo.asm`
- Linkear: `ld -o ejemplo ejemplo.o`
- Ejecutar: `./ejemplo`

## Como debuggear memory leaks

`valgrind --leak-check=yes ./<nombre_ejecutable>`
