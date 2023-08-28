# Organización del Computador 2 - 2do Cuat 2023

## Material de cursada de Organización del Computador II

- Taller 1 (Clase introductoria de Assembler)
	- [Ejercicio 1](Practica_Assembler_1/Ej1/holamundo.asm)
	- [Ejercicio 2](Practica_Assembler_1/Ej2/sumador.asm)
- [Taller 2](/Practica_2/)
	- [Lista enlazada](Practica_2/lista_enlazada.c)
	- [Vector](Practica_2/vector.c)

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