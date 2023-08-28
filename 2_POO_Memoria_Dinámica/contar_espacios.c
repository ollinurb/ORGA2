#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
	uint32_t res = 0;
	while(string != NULL && *string != '\0'){
		string++;
		res++;
	}
	return res;
}

uint32_t contar_espacios(char* string) {
	uint32_t res = 0;
	while(string != NULL && *string != '\0'){
		if(*string == ' '){
			res++;
		}
		string++;
	}
	return res;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/
