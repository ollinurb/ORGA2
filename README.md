#Instucciones para ensamblar, linkear y ejecutar.

- Ensamblar: `nasm -f elf64 -g -F DWARF ejemplo.asm`
- Linkear: `ld -o ejemplo ejemplo.o`
- Ejecutar: `./ejemplo`