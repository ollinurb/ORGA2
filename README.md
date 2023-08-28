# Organización del Computador 2 - 2do Cuat 2023

## Material de cursada de Organización del Computador II

- Taller 1 (Clase introductoria de Assembler)
	- [Ejercicio 1](1_Intro_Y_Assembler/Ej1/holamundo.asm)
	- [Ejercicio 2](1_Intro_Y_Assembler/Ej2/sumador.asm)
- [Taller 2](2_POO_Memoria_Dinámica/)
	- [Lista enlazada](2_POO_Memoria_Dinámica/lista_enlazada.c)
	- [Vector](2_POO_Memoria_Dinámica/vector.c)

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